#!/usr/bin/env python3
"""MAN.py - apply EDI replacements to MAN XML files (Python port of MAN.PS1).

Two jobs:
  1. Replace values in every *.xml in a directory, using replacements.txt
     (each line is  old,new  - literals, no regex; applied in file order).
  2. Optionally report the TD references whose <description> matches keywords
     such as TRANSHIPMENT / ZANZIBAR / CFS / CONSOLIDATION / SHIPPERS OWN.

Examples:
    python man.py --dir "C:\\EDI\\MAN" --dry-run
    python man.py --dir "C:\\EDI\\MAN" --backup
    python man.py --dir "C:\\EDI\\MAN" --keywords-only
    python man.py --dir "C:\\EDI\\MAN" --keywords-only --csv td_report.csv

Exit codes: 0 ok, 1 usage/IO error, 2 some files failed.
"""

from __future__ import annotations

import argparse
import csv
import io
import os
import re
import sys
import urllib.request
import xml.etree.ElementTree as ET
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

DEFAULT_URL = "https://raw.githubusercontent.com/lenadlm/edi-scripts/main/replacements.txt"

# (label, regex) - case-insensitive; word-ish boundaries to avoid false hits.
DEFAULT_KEYWORDS = [
    ("TRANSHIPMENT", r"transs?hipment"),
    ("ZANZIBAR", r"zanzibar"),
    ("CFS", r"\bcfs\b"),
    ("CONSOLIDATION", r"consolidat(?:ion|ed|ing)?"),
    ("SHIPPERS OWN", r"shipper['\u2019]?s\s+own"),
]


# ---------------------------------------------------------------- replacements
@dataclass
class Replacement:
    old: str
    new: str
    lineno: int
    hits: int = 0


def load_replacements(source: str) -> list[Replacement]:
    """Read replacements from an http(s) URL or a local path."""
    if re.match(r"^(https?)://", source, re.I):
        with urllib.request.urlopen(source, timeout=30) as resp:  # noqa: S310
            raw = resp.read()
    else:
        raw = Path(source).read_bytes()

    text = raw.decode("utf-8-sig")
    out: list[Replacement] = []
    seen: dict[tuple[str, str], int] = {}
    for i, line in enumerate(text.splitlines(), 1):
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        if "," not in s:
            print(f"  ! line {i}: no comma, skipped: {s!r}", file=sys.stderr)
            continue
        old, new = (p.strip() for p in s.split(",", 1))
        if not old:
            print(f"  ! line {i}: empty search value, skipped", file=sys.stderr)
            continue
        key = (old, new)
        if key in seen:
            continue  # duplicate - keep first occurrence (order parity with PS)
        seen[key] = i
        out.append(Replacement(old, new, i))
    return out


def apply_replacements(text: str, reps: list[Replacement]) -> tuple[str, int]:
    changed = 0
    for r in reps:
        n = text.count(r.old)
        if n:
            text = text.replace(r.old, r.new)
            r.hits += n
            changed += n
    return text, changed


# ------------------------------------------------------------------- encoding
def read_text(path: Path) -> tuple[str, str]:
    raw = path.read_bytes()
    if raw.startswith(b"\xef\xbb\xbf"):
        return raw.decode("utf-8-sig"), "utf-8-sig"
    if raw.startswith((b"\xff\xfe", b"\xfe\xff")):
        return raw.decode("utf-16"), "utf-16"
    return raw.decode("utf-8", errors="strict"), "utf-8"


def write_text(path: Path, text: str, encoding: str, backup: bool) -> None:
    if backup:
        stamp = datetime.now().strftime("%Y%m%d-%H%M%S")
        bak = path.with_suffix(path.suffix + f".{stamp}.bak")
        bak.write_bytes(path.read_bytes())
    tmp = path.with_suffix(path.suffix + ".tmp")
    tmp.write_bytes(text.encode(encoding))
    os.replace(tmp, path)


# ------------------------------------------------------------------- reporting
TD_CODE_RE = re.compile(r"<td_bill_code>\s*(.*?)\s*</td_bill_code>", re.S)


def changed_lines(before: str, after: str) -> list[tuple[int, str, str]]:
    b, a = before.splitlines(), after.splitlines()
    # replacements never add/remove newlines, so line i maps to line i
    return [(i, b[i], a[i]) for i in range(min(len(b), len(a))) if b[i] != a[i]]


def td_context(lines: list[str], upto: int) -> str:
    for i in range(upto, -1, -1):
        m = TD_CODE_RE.search(lines[i])
        if m:
            return m.group(1)
    return ""


@dataclass
class KeywordHit:
    file: str
    td_bill_code: str
    description: str
    matched: list[str] = field(default_factory=list)
    line: int = 0


def local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1]


def scan_keywords(path: Path, keywords) -> list[KeywordHit]:
    """Find every <td> whose <description> matches one of the keywords."""
    try:
        tree = ET.parse(path)
    except ET.ParseError as exc:
        print(f"  ! {path.name}: not well-formed XML ({exc}) - skipped", file=sys.stderr)
        return []

    # line numbers for <td_bill_code> occurrences, in file order
    try:
        text_lines = path.read_text(encoding="utf-8-sig", errors="replace").splitlines()
    except OSError:
        text_lines = []
    bill_lines = [(i + 1, m.group(1))
                  for i, ln in enumerate(text_lines)
                  for m in [TD_CODE_RE.search(ln)] if m]

    hits: list[KeywordHit] = []
    for el in tree.iter():
        if local_name(el.tag) != "td":
            continue
        code = desc = ""
        for child in el:
            name = local_name(child.tag)
            if name == "td_bill_code":
                code = (child.text or "").strip()
            elif name == "description":
                desc = " ".join((child.text or "").split())
        if not desc:
            continue
        matched = [label for label, rx in keywords if re.search(rx, desc, re.I)]
        if matched:
            # consume bill-code lines in document order so duplicates stay aligned
            line_no = 0
            while bill_lines and bill_lines[0][1] != code:
                bill_lines.pop(0)
            if bill_lines:
                line_no = bill_lines.pop(0)[0]
            hits.append(KeywordHit(path.name, code, desc, matched, line_no))
    return hits


# ------------------------------------------------------------------------ main
def main(argv: list[str]) -> int:
    ap = argparse.ArgumentParser(description="Apply EDI replacements to MAN XML files.")
    ap.add_argument("--dir", default=".", help="directory containing *.xml (default: .)")
    ap.add_argument("--replacements", default=DEFAULT_URL,
                    help="replacements.txt URL or local path")
    ap.add_argument("--dry-run", action="store_true", help="show changes, write nothing")
    ap.add_argument("--backup", action="store_true", help="keep a timestamped .bak per changed file")
    ap.add_argument("--no-replace", action="store_true", help="skip replacement pass")
    ap.add_argument("--keywords-only", action="store_true",
                    help="only run the keyword report (implies --no-replace)")
    ap.add_argument("--keywords", default="",
                    help="comma-separated extra regexes, e.g. 'DANGEROUS,REEFER'")
    ap.add_argument("--csv", help="write keyword report to this CSV file")
    ap.add_argument("--quiet", action="store_true", help="only print summaries")
    args = ap.parse_args(argv)

    root = Path(args.dir).expanduser()
    if not root.is_dir():
        print(f"error: not a directory: {root}", file=sys.stderr)
        return 1

    files = sorted(p for p in root.glob("*.xml") if p.is_file())
    if not files:
        print(f"error: no .xml files in {root}", file=sys.stderr)
        return 1

    do_replace = not (args.no_replace or args.keywords_only)
    failures = 0

    if do_replace:
        print(f"Loading replacements: {args.replacements}")
        try:
            reps = load_replacements(args.replacements)
        except Exception as exc:  # noqa: BLE001
            print(f"error fetching replacements: {exc}", file=sys.stderr)
            return 1
        print(f"  {len(reps)} unique rules\n")

        touched = 0
        for path in files:
            try:
                before, enc = read_text(path)
            except Exception as exc:  # noqa: BLE001
                print(f"Error reading file: {path}. Error: {exc}", file=sys.stderr)
                failures += 1
                continue

            after, n = apply_replacements(before, reps)
            if not n:
                if not args.quiet:
                    print(f"unchanged: {path.name}")
                continue

            touched += 1
            diffs = changed_lines(before, after)
            if not args.quiet:
                lines = before.splitlines()
                for idx, old_line, new_line in diffs:
                    fired = [r for r in reps if r.old in old_line]
                    print(f"TD Bill Code:            {td_context(lines, idx) or '-'}")
                    print(f"  line {idx + 1}")
                    for r in fired:
                        print(f"  rule replacements.txt:{r.lineno}: {r.old} -> {r.new}")
                    print(f"  - {old_line.strip()}")
                    print(f"  + {new_line.strip()}")
                print()

            if not args.dry_run:
                try:
                    write_text(path, after, enc, args.backup)
                except Exception as exc:  # noqa: BLE001
                    print(f"Error writing to file: {path}. Error: {exc}", file=sys.stderr)
                    failures += 1
                    continue
            if not args.quiet:
                verb = "would modify" if args.dry_run else "modified"
                print(f"{verb} file: {path}  ({n} replacement(s), {len(diffs)} line(s))\n")

        print(f"Files changed: {touched}/{len(files)}"
              f"{' (dry run, nothing written)' if args.dry_run else ''}")
        used = sum(1 for r in reps if r.hits)
        idle = [r for r in reps if not r.hits]
        print(f"Rules used: {used}/{len(reps)}")
        if idle and not args.quiet:
            print(f"  no match ({len(idle)}): "
                  + ", ".join(f"L{r.lineno}:{r.old}" for r in idle[:15])
                  + (" ..." if len(idle) > 15 else ""))
            print()

    # ---------------------------------------------------------- keyword report
    keywords = list(DEFAULT_KEYWORDS)
    for i, extra in enumerate(x for x in args.keywords.split(",") if x.strip()):
        keywords.append((extra.strip().upper(), re.escape(extra.strip())))

    hits: list[KeywordHit] = []
    for path in files:
        hits.extend(scan_keywords(path, keywords))

    print("TD references by description keyword")
    print("-" * 78)
    if not hits:
        print("none found")
    else:
        groups: dict[str, list[KeywordHit]] = {}
        for h in hits:
            for label in h.matched:
                groups.setdefault(label, []).append(h)
        for label, _ in keywords:
            rows = groups.get(label, [])
            print(f"\n{label}  ({len(rows)})")
            for h in rows:
                where = f"line {h.line}" if h.line else "line ?"
                print(f"  {h.td_bill_code:<14} {h.file} ({where})")
                print(f"  {'':<14} {h.description[:150]}")
        print(f"\nTotal matching TD elements: {len(hits)}")

    if args.csv:
        with open(args.csv, "w", newline="", encoding="utf-8-sig") as fh:
            w = csv.writer(fh)
            w.writerow(["keyword", "td_bill_code", "file", "line", "description"])
            for h in hits:
                for label in h.matched:
                    w.writerow([label, h.td_bill_code, h.file, h.line, h.description])
        print(f"CSV written: {args.csv}")

    print("\nAll files processed.")
    return 2 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

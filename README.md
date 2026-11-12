# edi-scripts
script to update selected edi files before pushing via sftp

## scripts/man.py (Python port of MAN.PS1)

Applies `replacements.txt` to every `*.xml` in a directory and reports TD
references whose description matches keywords.

```powershell
# preview (writes nothing)
python man.py --dir "C:\...\EDI\MAN" --dry-run

# apply, keeping a timestamped .bak beside each changed file
python man.py --dir "C:\...\EDI\MAN" --backup

# only the keyword report, plus a CSV
python man.py --dir "C:\...\EDI\MAN" --keywords-only --csv td_report.csv
```

Behaviour notes:
- Each `replacements.txt` line is `old,new`; values are literals (not regex) and
  run in file order, same as the PowerShell version. Duplicate rules are dropped.
- Files are written atomically, original encoding (UTF-8/UTF-8-BOM/UTF-16) and
  line endings are preserved. A second run is a no-op (idempotent).
- Keyword report parses `<td>` / `<td_bill_code>` / `<description>`; matches are
  case-insensitive: TRANSHIPMENT/TRANSSHIPMENT, ZANZIBAR, CFS (whole word),
  CONSOLIDATION, SHIPPERS OWN (straight or curly apostrophe). Add more with
  `--keywords A,B`.
- Every change is printed with the exact rule that fired (`replacements.txt:<line>: old -> new`),
  plus the TD bill code and line number. Nothing outside `replacements.txt` is ever modified.
- Malformed XML is reported to stderr and skipped; other files still process.
- Use `--replacements <path-or-url>` to pin a specific rules file.


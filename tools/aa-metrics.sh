#!/usr/bin/env bash
# Fetch Artificial Analysis model pages and write Intelligence Index, Cost per
# Task, and Time per Task from JSON-LD Datasets. Deterministic given the same
# HTML. python3 stdlib only. Not an installation process (README rules 25-27).
#
# usage: aa-metrics.sh [--help] [--dry-run] [--output-dir DIR] [--input-dir DIR]
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
AI_TOOLS=$(cd "$SCRIPT_DIR/.." && pwd)
UA="ai-tools-models/0.0.26-ALPHA"

usage() {
  cat <<'EOF'
usage: aa-metrics.sh [--help] [--dry-run] [--output-dir DIR] [--input-dir DIR]

Writes dev/wip/aa-metrics.csv. Unions JSON-LD datasets named
"Artificial Analysis Intelligence Index", "Cost per Task", and
"Time per Intelligence Index Task" from each fetched page.
A live run GETs English /models/<slug> locs from sitemap.xml, then each page.
--input-dir reads recorded HTML (*.html) and does not hit the network.
Requires python3. Live run also requires curl.
EOF
}

OUT_DIR="$AI_TOOLS/dev/wip"
IN_DIR=""
DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h) usage; exit 0 ;;
    --dry-run) DRY=1 ;;
    --output-dir) OUT_DIR="${2:-}"; [ -n "$OUT_DIR" ] || { echo "ERROR: --output-dir needs a value" >&2; exit 1; }; shift ;;
    --input-dir) IN_DIR="${2:-}"; [ -n "$IN_DIR" ] || { echo "ERROR: --input-dir needs a value" >&2; exit 1; }; shift ;;
    *) usage >&2; echo "ERROR: unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

command -v python3 >/dev/null 2>&1 || { echo "ERROR: python3 required" >&2; exit 1; }

if [ "$DRY" = 1 ]; then
  echo "would write $OUT_DIR/aa-metrics.csv"
  exit 0
fi

mkdir -p "$OUT_DIR" || exit 1
WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-aa.XXXXXX") || exit 1
trap 'rm -rf "$WORKDIR"' EXIT

if [ -n "$IN_DIR" ]; then
  n=0
  for f in "$IN_DIR"/*.html; do
    [ -f "$f" ] || continue
    cp "$f" "$WORKDIR/$(basename "$f")"
    n=$((n + 1))
  done
  [ "$n" -gt 0 ] || { echo "ERROR: no HTML in $IN_DIR" >&2; exit 1; }
else
  command -v curl >/dev/null 2>&1 || { echo "ERROR: curl required for a live run" >&2; exit 1; }
  if ! curl -fsSL -A "$UA" --max-time 60 "https://artificialanalysis.ai/sitemap.xml" -o "$WORKDIR/sitemap.xml"; then
    echo "ERROR: sitemap GET failed" >&2
    exit 1
  fi
  python3 - "$WORKDIR/sitemap.xml" "$WORKDIR/urls.txt" <<'PY'
import re, sys
from pathlib import Path
text = Path(sys.argv[1]).read_text(encoding="utf-8", errors="replace")
locs = re.findall(r"<loc>\s*(https://artificialanalysis.ai/models/[^<\s]+)\s*</loc>", text)
seen = []
for loc in locs:
    if "/es/" in loc or "/zh/" in loc or "/de/" in loc or "/ko/" in loc or "/ja/" in loc or "/pt/" in loc:
        continue
    if re.fullmatch(r"https://artificialanalysis.ai/models/[^/]+", loc) is None:
        continue
    if loc not in seen:
        seen.append(loc)
Path(sys.argv[2]).write_text("\n".join(seen) + ("\n" if seen else ""), encoding="utf-8")
print(f"sitemap model pages: {len(seen)}", file=sys.stderr)
PY
  [ -s "$WORKDIR/urls.txt" ] || { echo "ERROR: sitemap listed no English model pages" >&2; exit 1; }
  i=0
  while IFS= read -r url; do
    [ -n "$url" ] || continue
    i=$((i + 1))
    slug=${url##*/}
    if ! curl -fsSL -A "$UA" --max-time 60 "$url" -o "$WORKDIR/$slug.html"; then
      echo "SKIP: GET failed $url"
    fi
  done < "$WORKDIR/urls.txt"
  htmln=$(find "$WORKDIR" -maxdepth 1 -name '*.html' | wc -l | tr -d ' ')
  [ "$htmln" -gt 1 ] || { echo "ERROR: need sitemap-seeded model pages, not catalog-only" >&2; exit 1; }
fi

python3 - "$WORKDIR" "$OUT_DIR/aa-metrics.csv" <<'PY'
import csv, datetime, json, pathlib, re, sys
workdir, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
retrieved = datetime.date.today().isoformat()
wanted = {
    "Artificial Analysis Intelligence Index": ("intelligenceIndex", "intelligence_index"),
    "Cost per Task": ("costPerIntelligenceIndexTask", "cost_per_task"),
    "Time per Intelligence Index Task": ("timePerTask", "time_per_task"),
}
rows = {}
pages = 0
for htmlp in sorted(workdir.glob("*.html")):
    pages += 1
    html = htmlp.read_text(encoding="utf-8", errors="replace")
    for raw in re.findall(r'<script type="application/ld\+json">(.*?)</script>', html, re.S):
        try:
            data = json.loads(raw)
        except json.JSONDecodeError:
            continue
        items = data if isinstance(data, list) else [data]
        for d in items:
            if not isinstance(d, dict):
                continue
            spec = wanted.get(d.get("name"))
            if not spec:
                continue
            field, col = spec
            for item in d.get("data") or []:
                if not isinstance(item, dict) or field not in item or item[field] is None:
                    continue
                key = (item.get("label") or "", item.get("detailsUrl") or "")
                rec = rows.setdefault(key, {
                    "retrieved": retrieved,
                    "label": key[0],
                    "details_url": key[1],
                    "intelligence_index": "",
                    "cost_per_task": "",
                    "time_per_task": "",
                    "source_page": htmlp.name,
                })
                rec[col] = item[field]
print(f"pages={pages} keys={len(rows)}", file=sys.stderr)
with out.open("w", encoding="utf-8", newline="") as f:
    w = csv.DictWriter(f, fieldnames=[
        "retrieved", "label", "details_url",
        "intelligence_index", "cost_per_task", "time_per_task", "source_page",
    ])
    w.writeheader()
    for key in sorted(rows, key=lambda k: k[0]):
        w.writerow(rows[key])
print(f"wrote {out} ({len(rows)} rows)", file=sys.stderr)
PY
exit 0

#!/usr/bin/env bash
# Fetch each harness's official individual-plan pricing/models *markdown*
# and write a CSV of table (and Codex ModelDetails) rows.
# Deterministic given the same markdown: one GET per URL, python3 stdlib only.
# HTML SPAs are not a source — they omit the tables. Not an installation
# process (README rules 25-27).
#
# usage: harness-models.sh [--help] [--dry-run] [--output-dir DIR] [--input-dir DIR]
set -u
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
AI_TOOLS=$(cd "$SCRIPT_DIR/.." && pwd)
UA="ai-tools-models/0.0.26-ALPHA"

usage() {
  cat <<'EOF'
usage: harness-models.sh [--help] [--dry-run] [--output-dir DIR] [--input-dir DIR]

Writes dev/tmp/harness-models.csv. One GET of each harness's official
markdown pricing/models page (not the JS HTML). --input-dir uses recorded
files named <harness>.md and does not hit the network.
Requires python3. Live run also requires curl.
A harness that yields zero rows is skipped (exit 2).
EOF
}

OUT_DIR="$AI_TOOLS/dev/tmp"
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
  echo "would write $OUT_DIR/harness-models.csv"
  exit 0
fi

mkdir -p "$OUT_DIR" || exit 1
WORKDIR=$(mktemp -d "${TMPDIR:-/tmp}/ai-tools-harness.XXXXXX") || exit 1
trap 'rm -rf "$WORKDIR"' EXIT

# Official markdown. HTML SPAs (Codex learn.chatgpt.com, Antigravity HTML) do
# not embed the model tables; the .md siblings do.
PAGES='claude-code|https://code.claude.com/docs/en/model-config.md
grok|https://docs.x.ai/developers/models.md
codex|https://learn.chatgpt.com/docs/models.md
copilot|https://docs.github.com/en/copilot/reference/copilot-billing/models-and-pricing.md
cursor|https://cursor.com/docs/models-and-pricing.md
antigravity|https://antigravity.google/docs/models.md'

skipped=0
while IFS='|' read -r key url; do
  [ -n "$key" ] || continue
  dest="$WORKDIR/$key.md"
  if [ -n "$IN_DIR" ]; then
    if [ -f "$IN_DIR/$key.md" ]; then
      cp "$IN_DIR/$key.md" "$dest"
    else
      echo "SKIP: no fixture $IN_DIR/$key.md"
      skipped=$((skipped + 1))
      continue
    fi
  else
    command -v curl >/dev/null 2>&1 || { echo "ERROR: curl required for a live run" >&2; exit 1; }
    if ! curl -fsSL --compressed -A "$UA" --max-time 60 "$url" -o "$dest"; then
      echo "SKIP: GET failed $url"
      skipped=$((skipped + 1))
      continue
    fi
  fi
  printf '%s\t%s\n' "$key" "$url" >> "$WORKDIR/index.tsv"
done <<EOF
$PAGES
EOF

python3 - "$WORKDIR" "$OUT_DIR/harness-models.csv" <<'PY'
import csv, datetime, pathlib, re, sys

workdir, out = pathlib.Path(sys.argv[1]), pathlib.Path(sys.argv[2])
retrieved = datetime.date.today().isoformat()
index = {}
idxp = workdir / "index.tsv"
if idxp.exists():
    for line in idxp.read_text(encoding="utf-8", errors="replace").splitlines():
        key, url = line.split("\t", 1)
        index[key] = url

sep = re.compile(r"^\s*\|?\s*:?-{3,}")
pipe_row = re.compile(r"^\s*\|.*\|\s*$")


def cells_of(line):
    line = line.strip().strip("|")
    return [c.strip() for c in line.split("|")]


def md_table_rows(text):
    lines = text.splitlines()
    i = 0
    while i < len(lines):
        if pipe_row.match(lines[i]) and i + 1 < len(lines) and sep.match(lines[i + 1].replace(":", "")):
            block = [cells_of(lines[i])]
            i += 2
            while i < len(lines) and pipe_row.match(lines[i]):
                block.append(cells_of(lines[i]))
                i += 1
            for cells in block:
                if any(cells):
                    yield cells
            continue
        i += 1


def html_table_rows(text):
    for table in re.findall(r"<table[\s\S]*?</table>", text, re.I):
        for tr in re.findall(r"<tr[\s\S]*?</tr>", table, re.I):
            raw = re.findall(r"<t[hd][^>]*>([\s\S]*?)</t[hd]>", tr, re.I)
            cells = [" ".join(re.sub(r"<[^>]+>", "", c).split()) for c in raw]
            if cells:
                yield cells


def modeldetails_rows(text):
    # Codex (and similar MDX) lists models as <ModelDetails name="…" slug="…" description="…">
    for m in re.finditer(
        r"<ModelDetails\b([^>]*?)/?>",
        text,
        re.I | re.S,
    ):
        attrs = m.group(1)
        def attr(name):
            mm = re.search(rf'\b{name}\s*=\s*"([^"]*)"', attrs)
            return mm.group(1).strip() if mm else ""
        name, slug, desc = attr("name"), attr("slug"), attr("description")
        if name or slug:
            yield ["ModelDetails", name or slug, slug, desc]


rows = []
empty = []
for mdp in sorted(workdir.glob("*.md")):
    key = mdp.stem
    url = index.get(key, "")
    text = mdp.read_text(encoding="utf-8", errors="replace")
    n = 0
    for cells in list(md_table_rows(text)) + list(html_table_rows(text)) + list(modeldetails_rows(text)):
        rows.append({
            "retrieved": retrieved,
            "harness": key,
            "source_url": url,
            "cells": " | ".join(cells),
        })
        n += 1
    print(f"ok: {key} rows={n}", file=sys.stderr)
    if n == 0:
        empty.append(key)

with out.open("w", encoding="utf-8", newline="") as f:
    w = csv.DictWriter(f, fieldnames=["retrieved", "harness", "source_url", "cells"])
    w.writeheader()
    w.writerows(rows)
print(f"wrote {out} ({len(rows)} rows)", file=sys.stderr)
if empty:
    print("SKIP: zero rows: " + ",".join(empty), file=sys.stderr)
    sys.exit(2)
PY
status=$?
[ "$skipped" -gt 0 ] && [ "$status" -eq 0 ] && status=2
exit "$status"

#!/usr/bin/env bash
# Fetch OpenRouter benchmark rankings and a trimmed model list into data/benchmarks/.
# Each file is written only after its download and JSON check succeed, so a failed
# request leaves the previous snapshot in place.
set -euo pipefail

: "${OPENROUTER_API_KEY:?OPENROUTER_API_KEY is not set}"

API="https://openrouter.ai/api/v1"
OUT="${OUT_DIR:-data/benchmarks}"
mkdir -p "$OUT"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# fetch <url> <filename>: authenticated GET, validated JSON, then atomic move into $OUT.
fetch() {
  local url="$1" name="$2"
  curl -fsS --retry 3 --max-time 60 \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    "$url" -o "$tmp/$name"
  jq -e . "$tmp/$name" >/dev/null
  mv "$tmp/$name" "$OUT/$name"
  echo "wrote $OUT/$name"
}

fetch "$API/benchmarks?source=artificial-analysis&task_type=coding&max_results=50" aa-coding.json
fetch "$API/benchmarks?source=artificial-analysis&task_type=intelligence&max_results=50" aa-intelligence.json
fetch "$API/benchmarks?source=artificial-analysis&task_type=agentic&max_results=50" aa-agentic.json
fetch "$API/benchmarks?source=design-arena&max_results=50" design-arena.json

# Trimmed model list, for checking that a benchmark model_permaslug is routable.
curl -fsS --retry 3 --max-time 60 "$API/models" -o "$tmp/models-raw.json"
jq '{fetched_at: (now | todate),
     models: [.data[] | {id, canonical_slug, name, context_length, pricing}]}' \
  "$tmp/models-raw.json" > "$tmp/models.json"
mv "$tmp/models.json" "$OUT/models.json"
echo "wrote $OUT/models.json"

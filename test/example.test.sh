# shellcheck shell=bash
# Sourced by test/run.sh. The example brain must follow its own rules.

check "the example brain is within its limits" \
  "0" "$(bash "$root/skills/brain/check-limits.sh" "$root/example-brain" > /dev/null; echo $?)"

check "every group in the example map has a file" \
  "" "$(grep -v '^#' "$root/example-brain/map.tsv" | cut -f2 | sort -u |
        while read -r g; do [ -f "$root/example-brain/groups/$g" ] || echo "$g"; done)"

eh=$(mktemp -d)
check "the example map loads Northwind inside a product folder" \
  "# Northwind (own company)" \
  "$(jq -n --arg cwd "$eh/projects/scheduler/src" '{cwd: $cwd}' |
      HOME="$eh" SHARED_BRAIN_DIR="$root/example-brain" bash "$root/hooks/brain-context.sh" |
      sed -n 3p)"
rm -rf "$eh"

check "no em or en dash in the example brain" \
  "" "$(grep -rl $'\xe2\x80\x94\|\xe2\x80\x93' "$root/example-brain" || true)"

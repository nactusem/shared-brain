# shellcheck shell=bash
# Sourced by test/run.sh.

sandbox=$(mktemp -d)
brain="$sandbox/brain"
mkdir -p "$brain/groups" "$sandbox/work/acme"
echo "acme brain" > "$brain/groups/acme.md"
echo "northwind brain" > "$brain/groups/northwind.md"
echo "personal brain" > "$brain/groups/personal.md"
echo "not a brain" > "$sandbox/secret.md"
# The shorter prefix comes first for work/ and last for projects/, so both a
# first match and a last match implementation fail one of the checks below.
{
  echo "# folder prefix <TAB> group file"
  printf '%s\t%s\n' "~/work" "personal.md"
  printf '%s\t%s\n' "~/work/acme" "acme.md"
  printf '%s\t%s\n' "~/projects/invoicer/" "northwind.md"
  printf '%s\t%s\n' "~/projects" "personal.md"
  printf '%s\t%s\n' "~/projects/escape" "../../secret.md"
} > "$brain/map.tsv"

# run_hook <cwd> prints the hook output for a session started in <cwd>.
run_hook() {
  jq -n --arg cwd "$1" '{cwd: $cwd}' |
    HOME="$sandbox" SHARED_BRAIN_DIR="${BRAIN_UNDER_TEST:-$brain}" \
    SHARED_BRAIN_MAX_CHARS="${MAX_UNDER_TEST:-9500}" \
    bash "$root/hooks/brain-context.sh"
}

check "loads the group of the session folder" \
  "acme brain" "$(run_hook "$sandbox/work/acme/payments" | sed -n 3p)"

check "the longest prefix wins" \
  "northwind brain" "$(run_hook "$sandbox/projects/invoicer/src" | sed -n 3p)"

check "a sibling folder is not a child" \
  "personal brain" "$(run_hook "$sandbox/projects/invoicer-old" | sed -n 3p)"

check "prints nothing outside every group" \
  "" "$(run_hook "/somewhere/else")"

check "exits 0 outside every group" \
  "0" "$(run_hook "/somewhere/else" > /dev/null; echo $?)"

check "ignores a map entry that is a path" \
  "" "$(run_hook "$sandbox/projects/escape")"

check "prints nothing without a map" \
  "" "$(BRAIN_UNDER_TEST="$sandbox/missing" run_hook "$sandbox/work/acme")"

check "falls back to the working directory on bad input" \
  "acme brain" \
  "$(cd "$sandbox/work/acme" && echo 'not json' |
      HOME="$sandbox" SHARED_BRAIN_DIR="$brain" bash "$root/hooks/brain-context.sh" |
      sed -n 3p)"

run_hook "$sandbox/projects/\$(touch $sandbox/pwned)" > /dev/null
check "never evaluates the cwd" \
  "no" "$([ -e "$sandbox/pwned" ] && echo yes || echo no)"

check "truncates a group brain over the limit" \
  "[Truncated. Read $brain/groups/northwind.md for the rest.]" \
  "$(MAX_UNDER_TEST=5 run_hook "$sandbox/projects/invoicer" | tail -n 1)"

rm -rf "$sandbox"

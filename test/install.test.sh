# shellcheck shell=bash
# Sourced by test/run.sh.

ih=$(mktemp -d)
mkdir -p "$ih/.claude"
echo '{"model": "untouched"}' > "$ih/.claude/settings.json"

HOME="$ih" bash "$root/install.sh" > /dev/null

check "installs the empty starter brain, not the example" \
  "1 0" "$(grep -c 'Not filled in yet' "$ih/brain/MAP.md") $(grep -c Invoicer "$ih/brain/MAP.md")"

check "starts the brain as a git repo" \
  "yes" "$([ -d "$ih/brain/.git" ] && echo yes)"

check "installs the hook and the limit check" \
  "yes yes" \
  "$([ -f "$ih/.claude/hooks/brain-context.sh" ] && echo yes) $([ -f "$ih/.claude/skills/brain/check-limits.sh" ] && echo yes)"

check "points the skill at the brain" \
  "0 1" \
  "$(grep -c __BRAIN_DIR__ "$ih/.claude/skills/brain/SKILL.md") $(grep -c "^description: Updates the shared brain in $ih/brain " "$ih/.claude/skills/brain/SKILL.md")"

check "leaves Claude Code settings alone" \
  '{"model": "untouched"}' "$(cat "$ih/.claude/settings.json")"

echo "my own map" > "$ih/brain/MAP.md"
HOME="$ih" bash "$root/install.sh" > /dev/null
check "never overwrites an existing brain" \
  "my own map" "$(cat "$ih/brain/MAP.md")"

rm -rf "$ih"

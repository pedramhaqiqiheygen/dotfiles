#!/usr/bin/env bash
# Test harness for dev-lib.sh
set -u

# Use a fixture, not the user's live config.
FIXTURE=$(mktemp -t dev-lib-test.XXXXXX)
trap 'rm -f "$FIXTURE"' EXIT INT TERM
cat > "$FIXTURE" <<'EOF'
# Test fixture
gpu | nebius | ~/workspace  | 󰢮 | #a6e3a1 | true | g
aws | devbox | ~/workspaces | 󰅟 | #7aa2f7 | true | a

# Comment + blank lines should be ignored
EOF

export DEV_LIB_CONF_FILE="$FIXTURE"

# shellcheck source=./dev-lib.sh
source "$(dirname "$0")/dev-lib.sh"

PASS=0
FAIL=0

_assert_eq() {
  local label="$1" expected="$2" actual="$3"
  if [[ "$expected" == "$actual" ]]; then
    printf "  ✓ %s\n" "$label"; PASS=$((PASS+1))
  else
    printf "  ✗ %s\n    expected: %q\n    actual:   %q\n" "$label" "$expected" "$actual"; FAIL=$((FAIL+1))
  fi
}

# --- machines() ---
_assert_eq "machines() lists gpu,aws in order" "gpu,aws" "$(dev_lib::machines | tr '\n' ',' | sed 's/,$//')"

# --- machine_field ---
_assert_eq "machine_field gpu 2 (host)"  "nebius"   "$(dev_lib::machine_field gpu 2)"
_assert_eq "machine_field gpu 5 (color)" "#a6e3a1"  "$(dev_lib::machine_field gpu 5)"
_assert_eq "machine_field aws 4 (icon)"  "󰅟"        "$(dev_lib::machine_field aws 4)"
_assert_eq "machine_field nonexistent 2 (empty)" "" "$(dev_lib::machine_field nope 2)"

# --- machine_host / machine_color convenience wrappers ---
_assert_eq "machine_host aws"  "devbox"  "$(dev_lib::machine_host aws)"
_assert_eq "machine_color aws" "#7aa2f7" "$(dev_lib::machine_color aws)"

# --- display_width ---
_assert_eq "display_width '' = 0" "0" "$(dev_lib::display_width '')"
_assert_eq "display_width 'hello' = 5" "5" "$(dev_lib::display_width 'hello')"
_assert_eq "display_width '󰢮 GPU' = 6 (2+1+3)" "6" "$(dev_lib::display_width '󰢮 GPU')"

# --- truncate: trivial cases ---
_assert_eq "truncate('abc', 10) (no change)" "abc" "$(dev_lib::truncate 'abc' 10)"
_assert_eq "truncate('abc', 3) (equal width)" "abc" "$(dev_lib::truncate 'abc' 3)"

# --- truncate: long ASCII (leading ellipsis) ---
_assert_eq "truncate('prodai-prodai-planning', 12) leading ellipsis" "…ai-planning" "$(dev_lib::truncate 'prodai-prodai-planning' 12)"

# --- truncate: degenerate widths ---
_assert_eq "truncate('abc', 0) = empty" "" "$(dev_lib::truncate 'abc' 0)"
_assert_eq "truncate('abc', 1) = '…'" "…" "$(dev_lib::truncate 'abc' 1)"

# --- truncate: cell-aware when icon is in the kept tail ---
# 'a-󰢮GPU' = 1 + 1 + 2 + 3 = 7 cells. Truncate to 5 should NOT keep the icon.
# Expected: drop chars from left until used + ch_w <= 4 (budget). Walking right→left:
#   'U' (1): used=1; 'P' (1): used=2; 'G' (1): used=3; '󰢮' (2): used+2=5 > 4, STOP.
# Result: '…GPU' (1 ellipsis + 3 = width 4, fits in max=5; no icon).
_assert_eq "truncate cell-aware: icon in tail excluded" "…GPU" "$(dev_lib::truncate 'a-󰢮GPU' 5)"

# --- truncate: empty string ---
_assert_eq "truncate('', 5) = ''" "" "$(dev_lib::truncate '' 5)"

printf "\n%d passed, %d failed\n" "$PASS" "$FAIL"
exit "$FAIL"

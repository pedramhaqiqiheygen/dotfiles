#!/usr/bin/env bash
# Test harness for dev-lib.sh
set -u

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
machines_out=$(dev_lib::machines | tr '\n' ',' | sed 's/,$//')
_assert_eq "machines() includes gpu and aws" "gpu,aws" "$machines_out"

# --- machine_field ---
_assert_eq "machine_field gpu 2 (host)" "nebius" "$(dev_lib::machine_field gpu 2)"
_assert_eq "machine_field gpu 5 (color)" "#a6e3a1" "$(dev_lib::machine_field gpu 5)"

# --- display_width: ASCII ---
_assert_eq "display_width 'hello' = 5" "5" "$(dev_lib::display_width 'hello')"

# --- display_width: nerd-font icon (counts as 2 cells) ---
_assert_eq "display_width '󰢮 GPU' = 6 (2+1+3)" "6" "$(dev_lib::display_width '󰢮 GPU')"

# --- truncate: ASCII short string (no truncation) ---
_assert_eq "truncate('abc', 10) = 'abc'" "abc" "$(dev_lib::truncate 'abc' 10)"

# --- truncate: long ASCII (leading ellipsis) ---
_assert_eq "truncate('prodai-prodai-planning', 12) = '…ai-planning'" "…ai-planning" "$(dev_lib::truncate 'prodai-prodai-planning' 12)"

printf "\n%d passed, %d failed\n" "$PASS" "$FAIL"
exit "$FAIL"

#!/usr/bin/env bash
# dev-lib.sh — sourceable helpers shared by dev, dev-status, dev-jump, etc.
# Do NOT `set -e` here; consumers may need to handle individual failures.

if (( BASH_VERSINFO[0] < 4 )); then
  echo "dev-lib.sh requires bash 4+ (declare -A). Running under $BASH_VERSION." >&2
  return 1 2>/dev/null || exit 1
fi

DEV_LIB_CONF_FILE="${DEV_LIB_CONF_FILE:-$HOME/.config/dev/machines.conf}"

# Known nerd-font icons and their cell widths.
# Add to this map when introducing new machine icons.
declare -A DEV_LIB_ICON_WIDTH=(
  ["󰢮"]=2   # GPU
  ["󰅟"]=2   # AWS
  ["󰆍"]=2   # HOME / local terminal
  ["●"]=1
  ["◯"]=1
)

# Echo machine names, one per line.
dev_lib::machines() {
  [[ -f "$DEV_LIB_CONF_FILE" ]] || return 0
  awk -F'|' '!/^#/ && NF { gsub(/^[ \t]+|[ \t]+$/, "", $1); if ($1 != "") print $1 }' "$DEV_LIB_CONF_FILE"
}

# Echo Nth pipe-delimited field of a machine.
# Fields: 1=name 2=host 3=workspace 4=icon 5=color 6=show_on_status 7=key
dev_lib::machine_field() {
  local name="$1" field="$2"
  awk -F'|' -v n="$name" -v f="$field" '
    !/^#/ && NF {
      gsub(/^[ \t]+|[ \t]+$/, "", $1)
      if ($1 == n) {
        gsub(/^[ \t]+|[ \t]+$/, "", $f)
        print $f
        exit
      }
    }' "$DEV_LIB_CONF_FILE"
}

dev_lib::machine_host()   { dev_lib::machine_field "$1" 2; }
dev_lib::machine_icon()   { dev_lib::machine_field "$1" 4; }
dev_lib::machine_color()  { dev_lib::machine_field "$1" 5; }

# Echo @dev_machine of the current window. "local" if unset.
dev_lib::active_machine() {
  local m
  m=$(tmux display-message -p '#{@dev_machine}' 2>/dev/null)
  [[ -z "$m" ]] && m="local"
  printf '%s\n' "$m"
}

# Echo `<global_idx>|<display_name>` for each window where @dev_machine matches.
# Windows with @dev_machine unset are treated as "local".
dev_lib::windows_for() {
  local target="$1"
  tmux list-windows -a -F '#{window_index}|#{window_name}|#{@dev_machine}' 2>/dev/null \
    | awk -F'|' -v t="$target" '{
        m = ($3 == "") ? "local" : $3
        if (m == t) print $1 "|" $2
      }'
}

# Echo display-cell width of a string (ASCII = 1 cell, known icons from DEV_LIB_ICON_WIDTH).
# Cell-width of <s>. Unknown chars default to 1 cell (silent under-count for
# unmapped wide glyphs — add to DEV_LIB_ICON_WIDTH if introducing new icons).
dev_lib::display_width() {
  local s="$1" width=0 i=0 ch
  local -i len=${#s}
  while (( i < len )); do
    ch="${s:i:1}"
    if [[ -n "${DEV_LIB_ICON_WIDTH[$ch]:-}" ]]; then
      width=$(( width + DEV_LIB_ICON_WIDTH[$ch] ))
    else
      width=$(( width + 1 ))
    fi
    i=$(( i + 1 ))
  done
  printf '%d\n' "$width"
}

# Truncate <s> to <max> cells, prepending '…' if truncated.
# Preserves the suffix and is cell-aware (nerd-font icons count per DEV_LIB_ICON_WIDTH).
dev_lib::truncate() {
  local s="$1" max="$2"
  # Degenerate inputs: zero/negative width budget means empty output.
  if (( max <= 0 )); then
    printf '\n'
    return
  fi
  local w
  w=$(dev_lib::display_width "$s")
  if (( w <= max )); then
    printf '%s\n' "$s"
    return
  fi
  # Reserve 1 cell for the leading ellipsis.
  local budget=$(( max - 1 ))
  if (( budget <= 0 )); then
    printf '…\n'
    return
  fi
  # Walk from the right, accumulating cell widths until adding the next char would exceed budget.
  local i=$(( ${#s} - 1 ))
  local used=0 ch ch_w
  while (( i >= 0 )); do
    ch="${s:i:1}"
    ch_w="${DEV_LIB_ICON_WIDTH[$ch]:-1}"
    if (( used + ch_w > budget )); then
      break
    fi
    used=$(( used + ch_w ))
    i=$(( i - 1 ))
  done
  # Keep chars from index (i+1) to the end.
  printf '…%s\n' "${s:i+1}"
}

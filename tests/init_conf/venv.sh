#!/bin/sh

NVIM_BIN="nvim"

# Check if nvim exists, if not, print error and exit
if ! command -v "$NVIM_BIN" >/dev/null 2>&1; then
  echo "Error: nvim is not installed." >&2
  exit 1
fi

DIR="$( cd "$(dirname "$(readlink -f "$0")")" || exit ; pwd -P )"

TMP="$DIR/.tmp"
mkdir -p $TMP
# export VIMRUNTIM
export XDG_CONFIG_HOME="$TMP/.config"
export XDG_DATA_HOME="$TMP/.local/share"
export XDG_CACHE_HOME="$TMP/.cache"

"$NVIM_BIN" "$@"
rm -rf $TMP

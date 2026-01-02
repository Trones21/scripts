#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# mkcd — create a directory and cd into it
#
# Usage:
#   mkcd ./new-dir
#   mkcd /abs/path/new-dir
#
# Semantics:
#   - accepts exactly one argument
#   - supports:
#       * absolute paths (/foo/bar)
#       * ./relative paths
#   - rejects:
#       * bare relative paths (foo/bar)
#       * parent-relative paths (../foo)
#   - fails loudly instead of guessing
#
# Intended to be sourced:
#   source mkcd.sh
# -----------------------------------------------------------------------------

mkcd() {
  local dir="$1"

  # Validate input
  if [[ -z "$dir" ]]; then
    echo "mkcd: missing path argument" >&2
    return 1
  fi

  # Normalize / validate path
  case "$dir" in
    /*)
      # Absolute path — OK
      ;;
    ./*)
      # ./relative path — normalize
      dir="$PWD/${dir#./}"
      ;;
    *)
      echo "mkcd: unsupported path (expected absolute or ./relative): $dir" >&2
      return 1
      ;;
  esac

  # Create directory (including parents)
  mkdir -p "$dir" || {
    echo "mkcd: failed to create directory: $dir" >&2
    return 1
  }

  # Change directory
  cd "$dir" || {
    echo "mkcd: failed to cd into: $dir" >&2
    return 1
  }
}

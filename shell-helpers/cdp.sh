#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# cdp — change directory from pipeline input
#
# Usage:
#   find . -name agg | sed -n '1p' | cdp
#
# Semantics:
#   - accepts exactly one line from stdin
#   - supports:
#       * absolute paths (/foo/bar)
#       * ./relative paths
#   - rejects:
#       * bare relative paths (foo/bar)
#       * parent-relative paths (../foo)
#   - fails loudly instead of guessing
#
# Intended to be sourced:
#   source cdp.sh
# -----------------------------------------------------------------------------

cdp() {
  local dir

  # Read exactly one line from stdin
  if [[ -t 0 ]]; then
      echo "cdp — change directory from pipeline input"
      echo ""
      echo "Typical Usage: "
      echo "  find . -name <str> | sed -n '1p' | cdp "
      echo "  find . -wholename <str> | sed -n '1p' | cdp "
      echo "      -wholename allows for partial path wildcarding, e.g. *raw/SOL - where raw is actually /home/.../raw"
      echo "Semantics:"
      echo "   - accepts exactly one line from stdin"
      echo "   - supports:"
      echo "       * absolute paths (/foo/bar)"
      echo "       * ./relative paths"
      echo "   - rejects:"
      echo "       * bare relative paths (foo/bar)"
      echo "       * parent-relative paths (../foo)"
      echo "   - fails loudly instead of guessing"
      echo ""
      return 1
  fi


  IFS= read -r dir || {
    echo "cdp: no input on stdin" >&2
    echo "cdp: expects exactly one path" >&2
    echo "cdp: example: find . -name agg | sed -n '1p' | cdp" >&2
    return 1
  }

  if IFS= read -r extra; then
    echo "cdp: multiple lines on stdin" >&2
    echo "cdp: use sed -n '1p' or head -n 1" >&2
    return 1
  fi

  # Detect subshell (pipeline) execution
  if [[ $$ -ne $BASHPID ]]; then
    echo "cdp: pipeline detected; running in a subshell" >&2
    echo "cdp: 'cd' only affects the shell that executes it" >&2
    echo "cdp: You have two options:" >&2
    echo "  1. cdp \"\$(...)\"             # use command substitution instead of a pipeline" >&2
    echo "  2. shopt -s lastpipe; set +m   # both settings need to be applied" >&2
    echo "        shopt -s lastpipe             # run last pipeline command in the current shell" >&2
    echo "        set +m                        # disable job control (required for lastpipe)" >&2
   
    return 2
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
    "")
      echo "cdp: empty path" >&2
      return 1
      ;;
    *)
      echo "cdp: unsupported path (expected absolute or ./relative): $dir" >&2
      return 1
      ;;
  esac

  # Change directory
  cd "$dir" || {
    echo "cdp: failed to cd into: $dir" >&2
    return 1
  }
}

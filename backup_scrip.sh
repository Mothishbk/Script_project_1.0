# THIS PROVIDE AN STANDARD PROJECT EXAMPLE OF BACKUP SCRIPTING
# AUTHOR : MOTHISH BK
#!/usr/bin/env bash   #Environment friendly bash locator
set -euo pipefail     #Standard debug and error and exit option along with unset variable and pipefail validator
IFS=$'\n\t'           # Standard notation to make the value to be read by newline and tabs

#Below decalaration pattern adopts with the optional parameter setting so this helps in controlling the blast of failure if the expected option not set
dest_dir="${BACKUP_DEST:-$HOME/backups}"
log_file="${LOG_FILE:-}"
verbose="${VERBOSE:-0}"
#empty list declaration
declare -a sources=()
tmp_dir=""

log()  { local lvl="$1"; shift; printf '%s [%s] %s\n' "$(date '+%H:%M:%S')" "$lvl" "$*" >&2; }
info() { log INFO "$@"; }
warn() { log WARN "$@"; }
die()  { log ERROR "$@"; exit 1; }

cleanup() {
  local code=$?
  [[ -n "$tmp_dir" && -d "$tmp_dir" ]] && rm -rf "$tmp_dir"
  exit "$code"
}
trap cleanup EXIT INT TERM

run_step() { local title="$1"; shift; info "$title"; "$@"; }

usage() {
  cat <<EOF
backup.sh — archive folders into timestamped .tar.gz files.
Usage: backup.sh [-v] [-d DEST] FOLDER [FOLDER ...]
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -v|--verbose) verbose=1; shift ;;
      -d|--dest)    dest_dir="$2"; shift 2 ;;
      -h|--help)    usage; exit 0 ;;
      -*)           die "Unknown option: $1" ;;
      *)            sources+=("$1"); shift ;;
    esac
  done
}

main() {
  parse_args "$@"
  [[ ${#sources[@]} -gt 0 ]] || die "No folders given. Try: backup.sh ~/photos"

  if [[ -n "$log_file" ]]; then
    mkdir -p "$(dirname "$log_file")"
    exec > >(tee -a "$log_file") 2>&1
  fi

  mkdir -p "$dest_dir"
  tmp_dir="$(mktemp -d)"
  local stamp; stamp="$(date '+%Y-%m-%d-%H%M')"

  for src in "${sources[@]}"; do
    [[ -d "$src" ]] || die "Not a folder: $src"
    local name; name="$(basename "$src")"
    local archive="$tmp_dir/$name-$stamp.tar.gz"
    run_step "Archiving $src" tar -czf "$archive" "$src"
    mv "$archive" "$dest_dir/"
    info "Saved $dest_dir/$name-$stamp.tar.gz"
  done
  info "All done."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

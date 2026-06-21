#!/usr/bin/bash
set -euo pipefail
IFS=$'\n\t'



Logfile="${LOGFILE:-./cleaner_service.log}"
Threshold=60
sources=()

log() {
  local lvl="$1"; shift
  printf '%s [%s] %s\n' "$(date '+%H:%M:%S')" "$lvl" "$*" | tee -a "$Logfile" >&2
}

cleaner_service() {
  local threshold="$1"; shift
  local srcs=("$@")
  local source usage

  for source in "${srcs[@]}"; do
    if [[ ! -d "$source" ]]; then
      log "ERROR" "Source $source is not a valid directory."
      continue
    fi

    usage=$(df -h "${source}" | awk 'NR==2 {print $5}' | sed 's/%//')
    if (( usage > threshold )); then
      log "INFO" "Cleaning $source (usage ${usage}% > threshold ${threshold}%)."
      while IFS= read -r -d '' file; do
        rm -f "$file"
        log "INFO" "Deleted $file"
      done < <(find "$source" -type f -size +100M -print0)
    else
      log "INFO" "No cleanup needed for $source. Usage is ${usage}%."
    fi
  done
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        echo "Usage: $0 [options] /path/to/folder [/path/to/folder ...]"
        echo "Options:"
        echo "  -h, --help   Show this help message"
        exit 0
        ;;
      -*)
        echo "Unknown option: $1" >&2
        exit 1
        ;;
      *)
        sources+=("$1")
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"

  if (( ${#sources[@]} == 0 )); then
    echo "No sources provided. Use --help for usage." >&2
    exit 1
  fi

  cleaner_service "$Threshold" "${sources[@]}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

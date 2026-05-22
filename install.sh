#!/usr/bin/env bash
set -euo pipefail

PROFILE_NAME="${PROFILE_NAME:-tvOS}"
PROFILE_FILE="${PROFILE_FILE:-${PROFILE_NAME}.xml}"
PROFILE_URL="${PROFILE_URL:-https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/${PROFILE_FILE}}"
PLEX_SERVICE="${PLEX_SERVICE:-plexmediaserver}"
DEFAULT_PROFILE="/usr/lib/plexmediaserver/Resources/Profiles/${PROFILE_FILE}"

usage() {
  cat <<'EOF'
Install a Plex client profile from GitHub.

Usage:
  curl -fsSL https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/install.sh | sudo bash
  curl -fsSL https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/install.sh | sudo env PROFILE_NAME=iOS bash

Environment overrides:
  PROFILE_NAME  Profile client name, default: tvOS
  PROFILE_FILE  Profile file name, default: ${PROFILE_NAME}.xml
  PROFILE_URL   URL to download the profile XML from
  PROFILE_PATH  Exact profile path to replace
  PLEX_SERVICE  systemd service name, default: plexmediaserver
EOF
}

log() {
  printf '%s\n' "$*"
}

die() {
  printf 'Error: %s\n' "$*" >&2
  exit 1
}

require_root() {
  if [[ "${EUID}" -ne 0 ]]; then
    die "run this script as root, for example: curl -fsSL <install.sh-url> | sudo bash"
  fi
}

download_profile() {
  local destination="$1"

  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$PROFILE_URL" -o "$destination"
    return
  fi

  if command -v wget >/dev/null 2>&1; then
    wget -qO "$destination" "$PROFILE_URL"
    return
  fi

  die "curl or wget is required to download $PROFILE_URL"
}

cleanup() {
  if [[ -n "${TEMP_PROFILE:-}" ]]; then
    rm -f "$TEMP_PROFILE"
  fi
}

validate_profile() {
  local profile="$1"
  local token

  grep -q "<Client name=\"${PROFILE_NAME}\">" "$profile" || die "downloaded file does not look like a ${PROFILE_NAME} Plex profile"

  for token in $(required_tokens); do
    grep -q "$token" "$profile" || die "downloaded profile is missing expected token: $token"
  done

  if command -v xmllint >/dev/null 2>&1; then
    xmllint --noout "$profile"
  else
    log "xmllint not found; skipped XML parser validation"
  fi
}

required_tokens() {
  case "$PROFILE_NAME" in
    tvOS)
      printf '%s\n' hevc mpeg4 mjpeg heif tiff flac alac
      ;;
    iOS)
      printf '%s\n' hevc mpeg4 mjpeg prores heif tiff flac alac aiff wav caf
      ;;
  esac
}

verify_pattern() {
  case "$PROFILE_NAME" in
    tvOS)
      printf '%s\n' 'hevc|mpeg4|mjpeg|heif|tiff|flac|alac'
      ;;
    iOS)
      printf '%s\n' 'hevc|mpeg4|mjpeg|prores|heif|tiff|flac|alac|aiff|wav|caf'
      ;;
    *)
      printf '%s\n' 'Client name'
      ;;
  esac
}

find_profile_path() {
  local -a candidates=()
  local base
  local found

  if [[ -n "${PROFILE_PATH:-}" ]]; then
    [[ -f "$PROFILE_PATH" ]] || die "PROFILE_PATH does not exist: $PROFILE_PATH"
    printf '%s\n' "$PROFILE_PATH"
    return
  fi

  if [[ -f "$DEFAULT_PROFILE" ]]; then
    printf '%s\n' "$DEFAULT_PROFILE"
    return
  fi

  for base in /usr/lib/plexmediaserver /opt/plexmediaserver /var/lib/plexmediaserver /snap/plexmediaserver/current; do
    [[ -d "$base" ]] || continue
    while IFS= read -r found; do
      candidates+=("$found")
    done < <(find "$base" -type f -path "*/Resources/Profiles/${PROFILE_FILE}" 2>/dev/null)
  done

  if [[ "${#candidates[@]}" -eq 0 ]]; then
    die "could not locate ${PROFILE_FILE} automatically; set PROFILE_PATH=/path/to/${PROFILE_FILE}"
  fi

  if [[ "${#candidates[@]}" -gt 1 ]]; then
    printf 'Found multiple %s profiles:\n' "$PROFILE_FILE" >&2
    printf '  %s\n' "${candidates[@]}" >&2
    die "set PROFILE_PATH to the one you want to replace"
  fi

  printf '%s\n' "${candidates[0]}"
}

service_exists() {
  command -v systemctl >/dev/null 2>&1 && systemctl cat "$PLEX_SERVICE" >/dev/null 2>&1
}

main() {
  local profile_path
  local backup_path

  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_root

  TEMP_PROFILE="$(mktemp)"
  trap cleanup EXIT

  log "Downloading ${PROFILE_NAME} profile from:"
  log "  $PROFILE_URL"
  download_profile "$TEMP_PROFILE"
  validate_profile "$TEMP_PROFILE"

  profile_path="$(find_profile_path)"
  [[ -w "$(dirname "$profile_path")" ]] || die "profile directory is not writable: $(dirname "$profile_path")"

  backup_path="$profile_path.bak.$(date +%Y%m%d-%H%M%S)"

  log "Installing profile:"
  log "  target: $profile_path"
  log "  backup: $backup_path"

  if service_exists; then
    systemctl stop "$PLEX_SERVICE"
  else
    log "systemd service '$PLEX_SERVICE' not found; installing without service restart"
  fi

  cp -a "$profile_path" "$backup_path"
  install -o root -g root -m 0644 "$TEMP_PROFILE" "$profile_path"

  if service_exists; then
    systemctl start "$PLEX_SERVICE"
    systemctl --no-pager --full status "$PLEX_SERVICE" || true
  fi

  log "Installed updated ${PROFILE_NAME} Plex profile."
  log "Verify with:"
  log "  grep -nE '$(verify_pattern)' '$profile_path'"
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

PROFILE_URL="${PROFILE_URL:-https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/tvOS.xml}"
PLEX_SERVICE="${PLEX_SERVICE:-plexmediaserver}"
DEFAULT_PROFILE="/usr/lib/plexmediaserver/Resources/Profiles/tvOS.xml"

usage() {
  cat <<'EOF'
Install the tvOS Plex profile from GitHub.

Usage:
  curl -fsSL https://raw.githubusercontent.com/GeekStewie/tvOS-Profile-Plex/main/install.sh | sudo bash

Environment overrides:
  PROFILE_URL   URL to download tvOS.xml from
  PROFILE_PATH  Exact tvOS.xml path to replace
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

validate_profile() {
  local profile="$1"
  local token

  grep -q '<Client name="tvOS">' "$profile" || die "downloaded file does not look like a tvOS Plex profile"

  for token in hevc mpeg4 mjpeg heif tiff flac alac; do
    grep -q "$token" "$profile" || die "downloaded profile is missing expected token: $token"
  done

  if command -v xmllint >/dev/null 2>&1; then
    xmllint --noout "$profile"
  else
    log "xmllint not found; skipped XML parser validation"
  fi
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
    done < <(find "$base" -type f -path '*/Resources/Profiles/tvOS.xml' 2>/dev/null)
  done

  if [[ "${#candidates[@]}" -eq 0 ]]; then
    die "could not locate tvOS.xml automatically; set PROFILE_PATH=/path/to/tvOS.xml"
  fi

  if [[ "${#candidates[@]}" -gt 1 ]]; then
    printf 'Found multiple tvOS.xml profiles:\n' >&2
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
  local temp_profile
  local backup_path

  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    usage
    exit 0
  fi

  require_root

  temp_profile="$(mktemp)"
  trap 'rm -f "$temp_profile"' EXIT

  log "Downloading tvOS profile from:"
  log "  $PROFILE_URL"
  download_profile "$temp_profile"
  validate_profile "$temp_profile"

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
  install -o root -g root -m 0644 "$temp_profile" "$profile_path"

  if service_exists; then
    systemctl start "$PLEX_SERVICE"
    systemctl --no-pager --full status "$PLEX_SERVICE" || true
  fi

  log "Installed updated tvOS Plex profile."
  log "Verify with:"
  log "  grep -nE 'hevc|mpeg4|mjpeg|heif|tiff|flac|alac' '$profile_path'"
}

main "$@"

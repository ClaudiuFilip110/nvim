#!/usr/bin/env bash
set -euo pipefail

log() {
  printf "\033[1;34m[+] %s\033[0m\n" "$*"
}

warn() {
  printf "\033[1;33m[!] %s\033[0m\n" "$*" >&2
}

die() {
  printf "\033[1;31m[x] %s\033[0m\n" "$*" >&2
  exit 1
}

need_sudo() {
  if [ "$EUID" -eq 0 ]; then
    SUDO=""
  elif command -v sudo >/dev/null 2>&1; then
    SUDO="sudo"
  else
    die "This script needs root privileges. Install sudo or rerun as root."
  fi
}

detect_package_manager() {
  if command -v apt-get >/dev/null 2>&1; then
    PKG_MANAGER="apt"
  elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
  elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
  elif command -v zypper >/dev/null 2>&1; then
    PKG_MANAGER="zypper"
  else
    die "Unsupported distribution. Please install Neovim manually."
  fi
}

get_nvim_version() {
  if ! command -v nvim >/dev/null 2>&1; then
    return
  fi
  local version
  version="$(nvim --version | head -n1 | awk '{print $2}')"
  version="${version#v}"
  printf "%s" "${version}"
}

version_ge() {
  if [ "$(printf '%s\n' "$2" "$1" | sort -V | head -n1)" = "$2" ]; then
    return 0
  fi
  return 1
}

install_nvim() {
  detect_package_manager
  need_sudo
  
  log "Installing Neovim..."
  case "${PKG_MANAGER}" in
    apt)
      $SUDO apt-get update -y
      $SUDO apt-get install -y neovim
      ;;
    dnf)
      $SUDO dnf install -y neovim
      ;;
    pacman)
      $SUDO pacman -Sy --needed --noconfirm neovim
      ;;
    zypper)
      $SUDO zypper refresh
      $SUDO zypper install -y neovim
      ;;
  esac
}

check_version() {
  local current_version
  current_version="$(get_nvim_version || true)"
  
  if [ -z "${current_version}" ]; then
    die "Neovim installation failed or not found in PATH."
  fi
  
  if ! version_ge "${current_version}" "0.9.0"; then
    die "Neovim version ${current_version} is too old. Required: >= 0.9.0"
  fi
  
  log "Neovim ${current_version} installed successfully (>= 0.9.0)"
}

main() {
  install_nvim
  check_version
  log "All done. Neovim is ready to use."
}

main "$@"

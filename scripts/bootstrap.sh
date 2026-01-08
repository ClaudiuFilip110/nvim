#!/usr/bin/env bash
set -euo pipefail

REPO_SLUG="ClaudiuFilip110/nvim"
DEFAULT_REPO_URL="https://github.com/${REPO_SLUG}.git"
REPO_URL="${NVIM_REPO_URL:-$DEFAULT_REPO_URL}"
CONFIG_DIR="${HOME}/.config/nvim"

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
    die "This script needs root privileges to install packages. Install sudo or rerun as root."
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
    PKG_MANAGER=""
  fi
}

install_dependencies() {
  detect_package_manager
  if [ -z "${PKG_MANAGER}" ]; then
    die "Unsupported distribution. Please install Neovim, git, curl, ripgrep, and fzf manually."
  fi

  need_sudo
  case "${PKG_MANAGER}" in
    apt)
      $SUDO apt-get update -y
      $SUDO apt-get install -y neovim git curl ripgrep fzf build-essential unzip
      ;;
    dnf)
      $SUDO dnf install -y neovim git curl ripgrep fzf gcc make unzip
      ;;
    pacman)
      $SUDO pacman -Sy --needed --noconfirm neovim git curl ripgrep fzf base-devel unzip
      ;;
    zypper)
      $SUDO zypper refresh
      $SUDO zypper install -y neovim git curl ripgrep fzf gcc make unzip
      ;;
    *)
      die "Package manager ${PKG_MANAGER} is not handled."
      ;;
  esac
}

backup_existing_config() {
  if [ ! -d "${CONFIG_DIR}" ]; then
    return
  fi

  if [ -d "${CONFIG_DIR}/.git" ]; then
    local current_remote
    current_remote="$(git -C "${CONFIG_DIR}" remote get-url origin 2>/dev/null || true)"
    if [[ "${current_remote}" == *"${REPO_SLUG}"* ]]; then
      return
    fi
  fi

  local backup="${CONFIG_DIR}-backup-$(date +%Y%m%d%H%M%S)"
  mv "${CONFIG_DIR}" "${backup}"
  warn "Existing Neovim config moved to ${backup}"
}

sync_repo() {
  mkdir -p "$(dirname "${CONFIG_DIR}")"
  if [ -d "${CONFIG_DIR}/.git" ]; then
    log "Updating existing repo in ${CONFIG_DIR}"
    git -C "${CONFIG_DIR}" fetch origin
    git -C "${CONFIG_DIR}" pull --ff-only
  else
    log "Cloning ${REPO_URL} into ${CONFIG_DIR}"
    rm -rf "${CONFIG_DIR}"
    git clone "${REPO_URL}" "${CONFIG_DIR}"
  fi
}

bootstrap_lazy() {
  if ! command -v nvim >/dev/null 2>&1; then
    warn "Neovim binary not found after installation. Skipping plugin bootstrap."
    return
  fi

  log "Installing Lazy.nvim plugins (this can take a while)..."
  if nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1; then
    log "Plugins installed successfully."
  else
    warn "Automatic plugin installation failed. Open Neovim and run :Lazy sync manually."
  fi
}

main() {
  log "Installing base dependencies..."
  install_dependencies
  backup_existing_config
  sync_repo
  bootstrap_lazy
  log "All done. Launch Neovim with 'nvim' to finish any interactive setup."
}

main "$@"

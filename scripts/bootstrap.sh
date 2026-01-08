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

install_build_dependencies() {
  detect_package_manager
  need_sudo
  
  log "Installing build dependencies..."
  case "${PKG_MANAGER}" in
    apt)
      $SUDO apt-get update -y
      $SUDO apt-get install -y git cmake make ninja-build gettext curl \
        gcc g++ libtool libtool-bin autoconf automake pkg-config \
        unzip libunibilium-dev libmsgpack-dev libvterm-dev \
        libluajit-5.1-dev lua5.1 liblua5.1-dev
      ;;
    dnf)
      $SUDO dnf install -y git cmake make ninja-build gettext curl \
        gcc gcc-c++ libtool autoconf automake pkg-config \
        unzip libunibilium-devel msgpack-devel libvterm-devel \
        luajit-devel lua-devel
      ;;
    pacman)
      $SUDO pacman -Sy --needed --noconfirm git cmake make ninja gettext curl \
        gcc libtool autoconf automake pkg-config \
        unzip libunibilium msgpack-c libvterm \
        luajit lua
      ;;
    zypper)
      $SUDO zypper refresh
      $SUDO zypper install -y git cmake make ninja gettext curl \
        gcc gcc-c++ libtool autoconf automake pkg-config \
        unzip libunibilium-devel msgpack-devel libvterm-devel \
        luajit-devel lua-devel
      ;;
  esac
}

install_nvim() {
  need_sudo
  local build_dir=""
  
  install_build_dependencies
  
  build_dir="$(mktemp -d)"
  trap "rm -rf ${build_dir}" EXIT
  
  log "Cloning Neovim repository..."
  if ! git clone --depth 1 https://github.com/neovim/neovim.git "${build_dir}"; then
    die "Failed to clone Neovim repository"
  fi
  
  cd "${build_dir}"
  
  log "Building Neovim (this may take a while)..."
  if ! make CMAKE_BUILD_TYPE=RelWithDebInfo; then
    die "Failed to build Neovim"
  fi
  
  log "Installing Neovim..."
  $SUDO make install
  
  cd - >/dev/null
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
  local current_version
  current_version="$(get_nvim_version || true)"
  
  if [ -n "${current_version}" ] && version_ge "${current_version}" "0.9.0"; then
    log "Neovim ${current_version} is already installed (>= 0.9.0)"
    return 0
  fi
  
  if [ -n "${current_version}" ]; then
    warn "Current Neovim version ${current_version} is too old. Upgrading..."
  fi
  
  install_nvim
  check_version
  log "All done. Neovim is ready to use."
}

main "$@"

#!/usr/bin/env bash
set -euo pipefail

# Usage: ./sync-to-remote.sh [pod-name]
# If pod-name is not provided, it will try to find the hmnd pod automatically

log() {
  printf "\033[1;34m[+] %s\033[0m\n" "$*"
}

die() {
  printf "\033[1;31m[x] %s\033[0m\n" "$*" >&2
  exit 1
}

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NVIM_CONFIG_DIR="$(dirname "$SCRIPT_DIR")"

# Find or use provided pod name
if [ $# -ge 1 ]; then
  POD_NAME="$1"
else
  log "Looking for hmnd pod..."
  POD_NAME=$(kubectl get pods | grep hmnd-interactive-base-pod | awk '{print $1}' | head -n1)
  
  if [ -z "$POD_NAME" ]; then
    die "Could not find hmnd pod. Please provide pod name as argument."
  fi
  
  log "Found pod: $POD_NAME"
fi

# Create .config/nvim directory on remote
log "Creating .config/nvim directory on remote..."
kubectl exec "$POD_NAME" -- mkdir -p /root/.config/nvim/lua/clau /root/.config/nvim/scripts

# Copy all config files
log "Copying config files..."
kubectl cp "$NVIM_CONFIG_DIR/init.lua" "$POD_NAME:/root/.config/nvim/init.lua"
kubectl cp "$NVIM_CONFIG_DIR/lua/clau" "$POD_NAME:/root/.config/nvim/lua/"

# Copy scripts
log "Copying scripts..."
kubectl cp "$NVIM_CONFIG_DIR/scripts/bootstrap.sh" "$POD_NAME:/root/.config/nvim/scripts/bootstrap.sh"

# Make bootstrap script executable
kubectl exec "$POD_NAME" -- chmod +x /root/.config/nvim/scripts/bootstrap.sh

log "Config synced successfully!"
log "Now you can SSH/exec into the pod and run: nvim"
log "Lazy will auto-install on first run."


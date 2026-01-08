# Claudiu's Neovim Config

This repo lives in `~/.config/nvim` and contains everything needed to reproduce the setup on a fresh Linux machine.

## Quick install

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/ClaudiuFilip110/nvim/main/scripts/bootstrap.sh)
```

What the script does:

- Installs Neovim plus required helpers (`git`, `curl`, `ripgrep`, `fzf`, build tools) for apt, dnf, pacman, or zypper based distros.
- Verifies the installed Neovim version and automatically drops the official AppImage into `/usr/local/bin` if the system package is older than `0.8.0`.
- Backs up any existing `~/.config/nvim` that does not point to this repo.
- Clones or updates the repo and runs `Lazy! sync` headlessly so plugins are installed.

### Customising the repo source

Set `NVIM_REPO_URL` if you want to pull from a fork or a different remote:

```bash
NVIM_REPO_URL=git@github.com:ClaudiuFilip110/nvim.git bash <(curl -fsSL https://raw.githubusercontent.com/ClaudiuFilip110/nvim/main/scripts/bootstrap.sh)
```

### Offline / already downloaded usage

If the repo is already cloned locally, run the script directly:

```bash
chmod +x scripts/bootstrap.sh
scripts/bootstrap.sh
```

### After installation

- Launch `nvim` normally to verify everything is synced.
- Use `:Mason` to install extra LSPs or linters as needed.

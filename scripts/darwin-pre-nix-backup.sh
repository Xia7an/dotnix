#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  darwin-pre-nix-backup.sh [BACKUP_DIR]

Creates a pre-migration snapshot for macOS before switching this host to
declarative Nix management.

Default output:
  ~/Backups/dotnix-pre-nix/<LocalHostName>-pre-nix-<timestamp>
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

log() {
  printf '[backup] %s\n' "$*"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

host_name="$(
  scutil --get LocalHostName 2>/dev/null \
    || hostname -s 2>/dev/null \
    || echo "darwin"
)"
timestamp="$(date +%Y%m%d-%H%M%S)"
default_root="$HOME/Backups/dotnix-pre-nix"
backup_dir="${1:-$default_root/${host_name}-pre-nix-${timestamp}}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

mkdir -p \
  "$backup_dir/archives" \
  "$backup_dir/inventory/apps" \
  "$backup_dir/inventory/brew" \
  "$backup_dir/inventory/system" \
  "$backup_dir/manifest" \
  "$backup_dir/scripts"

log "backup directory: $backup_dir"

paths=(
  ".config"
  ".hammerspoon"
  ".aerospace.toml"
  ".zshrc"
  ".zprofile"
  ".zlogin"
  ".zlogout"
  ".p10k.zsh"
  ".bashrc"
  ".bash_profile"
  ".gitconfig"
  ".tmux.conf"
  ".skk-jisyo"
  "Library/Application Support/AquaSKK"
  "Library/Application Support/com.raycast.macos"
  "Library/Application Support/iTerm2"
  "Library/Application Support/Logi"
  "Library/Preferences/jp.sourceforge.inputmethod.aquaskk.plist"
  "Library/Preferences/com.googlecode.iterm2.plist"
  "Library/Preferences/com.lwouis.alt-tab-macos.plist"
  "Library/Preferences/com.jordanbaird.Ice.plist"
  "Library/Preferences/org.hammerspoon.Hammerspoon.plist"
  "Library/Preferences/com.raycast.macos.plist"
)

existing_paths=()
missing_paths=()
for rel in "${paths[@]}"; do
  if [[ -e "$HOME/$rel" || -L "$HOME/$rel" ]]; then
    existing_paths+=("$rel")
  else
    missing_paths+=("$rel")
  fi
done

printf '%s\n' "${existing_paths[@]}" > "$backup_dir/manifest/paths.txt"
printf '%s\n' "${missing_paths[@]}" > "$backup_dir/manifest/missing-paths.txt"

if ((${#existing_paths[@]} > 0)); then
  log "archiving home state"
  /usr/bin/tar -czf "$backup_dir/archives/home-state.tar.gz" -C "$HOME" "${existing_paths[@]}"
else
  log "no configured paths found under \$HOME; home-state archive skipped"
fi

log "recording system inventory"
{
  echo "created_at=$(date -Iseconds)"
  echo "host_name=$host_name"
  echo "backup_dir=$backup_dir"
  echo "repo_root=$repo_root"
} > "$backup_dir/manifest/metadata.env"

{
  echo "repo_root=$repo_root"
  git -C "$repo_root" rev-parse HEAD 2>/dev/null | sed 's/^/repo_rev=/'
  git -C "$repo_root" status --short 2>/dev/null || true
} > "$backup_dir/inventory/system/dotnix-repo.txt"

if have_cmd sw_vers; then
  sw_vers > "$backup_dir/inventory/system/sw_vers.txt"
fi

if have_cmd pkgutil; then
  pkgutil --pkgs | sort > "$backup_dir/inventory/system/pkgutil-packages.txt"
fi

if have_cmd mas; then
  mas list > "$backup_dir/inventory/system/mas-list.txt" || true
fi

if [[ -d /Applications ]]; then
  find /Applications -maxdepth 1 -type d -name '*.app' -print | sort \
    > "$backup_dir/inventory/apps/system-applications.txt"
fi

if [[ -d "$HOME/Applications" ]]; then
  find "$HOME/Applications" -maxdepth 1 -type d -name '*.app' -print | sort \
    > "$backup_dir/inventory/apps/user-applications.txt"
fi

if have_cmd brew; then
  log "recording Homebrew state"
  brew list --formula | sort > "$backup_dir/inventory/brew/formulae.txt"
  brew leaves | sort > "$backup_dir/inventory/brew/leaves.txt"
  brew list --cask | sort > "$backup_dir/inventory/brew/casks.txt"
  brew tap | sort > "$backup_dir/inventory/brew/taps.txt"
  brew bundle dump --force --describe --file "$backup_dir/inventory/brew/Brewfile" >/dev/null
else
  log "Homebrew not found; brew inventory skipped"
fi

cp "$repo_root/scripts/darwin-pre-nix-restore.sh" "$backup_dir/scripts/"
chmod +x "$backup_dir/scripts/darwin-pre-nix-restore.sh"

cat > "$backup_dir/RESTORE_README.txt" <<EOF
Pre-Nix migration snapshot created at:
  $(date -Iseconds)

Primary contents:
  archives/home-state.tar.gz
  inventory/brew/Brewfile
  inventory/apps/
  inventory/system/
  manifest/paths.txt

Restore preview:
  $backup_dir/scripts/darwin-pre-nix-restore.sh "$backup_dir"

Restore execution:
  $backup_dir/scripts/darwin-pre-nix-restore.sh --yes --restore-brew "$backup_dir"

Notes:
  - The restore script reapplies the saved home files over the current \$HOME.
  - Homebrew restore is best-effort and only covers packages represented in Brewfile.
  - Non-Homebrew GUI apps are inventoried, but may still require manual reinstall.
EOF

log "snapshot complete"
log "preview restore with: $backup_dir/scripts/darwin-pre-nix-restore.sh \"$backup_dir\""

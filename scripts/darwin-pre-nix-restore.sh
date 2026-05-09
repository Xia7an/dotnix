#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  darwin-pre-nix-restore.sh [--yes] [--restore-brew] BACKUP_DIR

Default behavior is preview-only. Pass --yes to actually write files back into
$HOME. Pass --restore-brew to also replay the saved Homebrew Brewfile.
EOF
}

log() {
  printf '[restore] %s\n' "$*"
}

die() {
  printf '[restore] %s\n' "$*" >&2
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

run_restore=false
restore_brew=false
backup_dir=""

while (($# > 0)); do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    --yes)
      run_restore=true
      shift
      ;;
    --restore-brew)
      restore_brew=true
      shift
      ;;
    --*)
      die "unknown option: $1"
      ;;
    *)
      if [[ -n "$backup_dir" ]]; then
        die "backup directory specified more than once"
      fi
      backup_dir="$1"
      shift
      ;;
  esac
done

[[ -n "$backup_dir" ]] || die "backup directory is required"
[[ -d "$backup_dir" ]] || die "backup directory not found: $backup_dir"
[[ -f "$backup_dir/manifest/paths.txt" ]] || die "manifest/paths.txt not found in $backup_dir"

log "backup directory: $backup_dir"

if ! $run_restore; then
  log "preview mode only; no files will be modified"
  log "paths to restore:"
  sed 's/^/  - /' "$backup_dir/manifest/paths.txt"
  if $restore_brew; then
    log "Homebrew restore would use: $backup_dir/inventory/brew/Brewfile"
  fi
  log "rerun with --yes to apply"
  exit 0
fi

archive="$backup_dir/archives/home-state.tar.gz"
tmpdir="$(mktemp -d "${TMPDIR:-/tmp}/dotnix-pre-nix-restore.XXXXXX")"
trap 'rm -rf "$tmpdir"' EXIT

if [[ -f "$archive" ]]; then
  log "extracting archive"
  /usr/bin/tar -xzf "$archive" -C "$tmpdir"
else
  log "home-state archive not found; file restore skipped"
fi

while IFS= read -r rel; do
  [[ -n "$rel" ]] || continue

  src="$tmpdir/$rel"
  dst="$HOME/$rel"

  if [[ ! -e "$src" && ! -L "$src" ]]; then
    log "skipping missing archived path: $rel"
    continue
  fi

  mkdir -p "$(dirname "$dst")"

  if [[ -L "$dst" ]]; then
    rm -f "$dst"
  fi

  if [[ -d "$src" && ! -L "$src" ]]; then
    if [[ -e "$dst" && ! -d "$dst" ]]; then
      rm -f "$dst"
    fi
    mkdir -p "$dst"
    /usr/bin/rsync -a --delete "$src/" "$dst/"
    log "restored directory: $rel"
  else
    if [[ -d "$dst" && ! -L "$dst" ]]; then
      log "skipping file restore because destination is a directory: $rel"
      continue
    fi
    cp -a "$src" "$dst"
    log "restored file: $rel"
  fi
done < "$backup_dir/manifest/paths.txt"

if $restore_brew; then
  brewfile="$backup_dir/inventory/brew/Brewfile"
  if [[ ! -f "$brewfile" ]]; then
    log "Brewfile not found; Homebrew restore skipped"
  elif ! have_cmd brew; then
    log "brew is not installed; Homebrew restore skipped"
  else
    log "restoring Homebrew packages from Brewfile"
    brew bundle install --file "$brewfile" --no-lock
  fi
fi

log "restore complete"

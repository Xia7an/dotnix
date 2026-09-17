#!/usr/bin/env bash

# Shared functions for setup-nixos.sh and setup-linux-general.sh.

setup_log() {
  printf '[dotnix-setup] %s\n' "$*"
}

setup_die() {
  printf '[dotnix-setup] error: %s\n' "$*" >&2
  exit 1
}

setup_repo_root() {
  cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd
}

setup_require_linux() {
  [[ "$(uname -s)" == "Linux" ]] || setup_die "this setup script only supports Linux"
}

setup_user_name() {
  local user_name="${SUDO_USER:-${USER:-}}"

  ((EUID != 0)) || setup_die "run this script as the user Home Manager should manage, not as root"
  [[ -n "$user_name" ]] || user_name="$(id -un)"
  [[ "$user_name" != "root" ]] || setup_die "the Home Manager user cannot be root"
  [[ "$user_name" =~ ^[a-z_][a-z0-9_-]*$ ]] || setup_die "unsupported user name: $user_name"
  printf '%s\n' "$user_name"
}

setup_user_home() {
  local user_name="$1"
  local passwd_entry=""
  local home_directory=""

  if command -v getent >/dev/null 2>&1; then
    passwd_entry="$(getent passwd "$user_name" || true)"
    if [[ -n "$passwd_entry" ]]; then
      IFS=: read -r _ _ _ _ _ home_directory _ <<< "$passwd_entry"
    fi
  fi

  if [[ -z "$home_directory" && "$user_name" == "${USER:-}" ]]; then
    home_directory="${HOME:-}"
  fi
  [[ -n "$home_directory" ]] || home_directory="/home/$user_name"
  [[ "$home_directory" == /* ]] || setup_die "home directory must be an absolute path: $home_directory"
  printf '%s\n' "$home_directory"
}

setup_nix_system() {
  case "$(uname -m)" in
    x86_64)
      printf 'x86_64-linux\n'
      ;;
    aarch64|arm64)
      printf 'aarch64-linux\n'
      ;;
    *)
      setup_die "unsupported architecture: $(uname -m)"
      ;;
  esac
}

setup_host_name() {
  local host_name="${1:-}"

  if [[ -z "$host_name" ]]; then
    [[ -t 0 ]] || setup_die "pass the host name as the first argument when stdin is not interactive"
    read -r -p 'Host name: ' host_name
  fi

  [[ ${#host_name} -le 63 ]] || setup_die "host name must be at most 63 characters"
  [[ "$host_name" =~ ^[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$ ]] \
    || setup_die "host name may only contain letters, digits, and internal hyphens"
  printf '%s\n' "$host_name"
}

setup_escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[&|\\]/\\&/g'
}

setup_create_host() {
  local repo_root="$1"
  local template_name="$2"
  local host_name="$3"
  local user_name="$4"
  local home_directory="$5"
  local nix_system="$6"
  local hardware_source="${7:-}"
  local template_directory="$repo_root/template/$template_name"
  local target_directory="$repo_root/hosts/$host_name"
  local temporary_directory=""
  local file=""
  local escaped_host escaped_user escaped_home escaped_system

  [[ -d "$template_directory" ]] || setup_die "template not found: $template_directory"
  [[ ! -e "$target_directory" ]] || setup_die "host already exists: $target_directory"

  temporary_directory="$(mktemp -d "$repo_root/.new-host.XXXXXX")"
  if ! cp -R "$template_directory/." "$temporary_directory/"; then
    rm -rf "$temporary_directory"
    setup_die "failed to copy the host template"
  fi

  escaped_host="$(setup_escape_sed_replacement "$host_name")"
  escaped_user="$(setup_escape_sed_replacement "$user_name")"
  escaped_home="$(setup_escape_sed_replacement "$home_directory")"
  escaped_system="$(setup_escape_sed_replacement "$nix_system")"

  while IFS= read -r -d '' file; do
    sed \
      -e "s|__HOST_NAME__|$escaped_host|g" \
      -e "s|__USER_NAME__|$escaped_user|g" \
      -e "s|__HOME_DIRECTORY__|$escaped_home|g" \
      -e "s|__SYSTEM__|$escaped_system|g" \
      "$file" > "$file.tmp"
    mv "$file.tmp" "$file"
  done < <(find "$temporary_directory" -type f -print0)

  if [[ -n "$hardware_source" ]]; then
    if ! install -m 0644 "$hardware_source" "$temporary_directory/hardware.nix"; then
      rm -rf "$temporary_directory"
      setup_die "failed to copy $hardware_source"
    fi
  fi

  mv "$temporary_directory" "$target_directory"
  setup_log "created hosts/$host_name from template/$template_name"
}

setup_load_nix() {
  local profile_script=""

  if command -v nix >/dev/null 2>&1; then
    return 0
  fi

  for profile_script in \
    "$HOME/.nix-profile/etc/profile.d/nix.sh" \
    /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh; do
    if [[ -r "$profile_script" ]]; then
      # shellcheck disable=SC1090
      source "$profile_script"
    fi
  done

  command -v nix >/dev/null 2>&1
}

setup_install_nix() {
  local temporary_directory=""
  local installer=""

  if setup_load_nix; then
    setup_log "Nix is already installed: $(nix --version)"
    return 0
  fi

  if [[ ! -d /nix ]]; then
    setup_log "the Nix installer may request administrator rights once to create /nix"
  else
    setup_log "using the existing /nix directory for a single-user installation"
  fi

  temporary_directory="$(mktemp -d "${TMPDIR:-/tmp}/dotnix-install.XXXXXX")"
  installer="$temporary_directory/install-nix"

  if command -v curl >/dev/null 2>&1; then
    curl --proto '=https' --tlsv1.2 --fail --location https://nixos.org/nix/install --output "$installer"
  elif command -v wget >/dev/null 2>&1; then
    wget --https-only --output-document="$installer" https://nixos.org/nix/install
  else
    rm -rf "$temporary_directory"
    setup_die "curl or wget is required to install Nix"
  fi

  if ! sh "$installer" --no-daemon; then
    rm -rf "$temporary_directory"
    setup_die "Nix installation failed"
  fi
  rm -rf "$temporary_directory"

  setup_load_nix || setup_die "Nix was installed but is not available in this shell"
  setup_log "installed $(nix --version)"
}

setup_enable_flakes() {
  local required_features='experimental-features = nix-command flakes'

  if [[ -n "${NIX_CONFIG:-}" ]]; then
    export NIX_CONFIG="${NIX_CONFIG}"$'\n'"$required_features"
  else
    export NIX_CONFIG="$required_features"
  fi
}

setup_home_manager_switch() {
  local repo_root="$1"
  local host_name="$2"
  local flake_ref="path:$repo_root"

  setup_log "activating Home Manager configuration ${host_name}Home"
  nix run "$flake_ref#home-manager" -- switch --flake "$flake_ref#${host_name}Home"
}

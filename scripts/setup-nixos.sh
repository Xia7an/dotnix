#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/setup-host-common.sh
source "$script_directory/lib/setup-host-common.sh"

usage() {
  cat <<'EOF'
Usage: scripts/setup-nixos.sh [HOST_NAME]

Creates hosts/HOST_NAME from template/nixos, copies the current NixOS
hardware configuration, and activates NixOS and Home Manager. If HOST_NAME is
omitted, the script prompts for it.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
[[ $# -le 1 ]] || setup_die "usage: scripts/setup-nixos.sh [HOST_NAME]"

setup_require_linux
[[ -e /etc/NIXOS || -e /run/current-system/nixos-version ]] \
  || setup_die "this does not appear to be a NixOS system"

hardware_source="/etc/nixos/hardware-configuration.nix"
[[ -r "$hardware_source" ]] || setup_die "hardware configuration not readable: $hardware_source"
command -v nixos-rebuild >/dev/null 2>&1 || setup_die "nixos-rebuild is not available"
command -v sudo >/dev/null 2>&1 || setup_die "sudo is required for nixos-rebuild switch"

repo_root="$(setup_repo_root)"
host_name="$(setup_host_name "${1:-}")"
user_name="$(setup_user_name)"
home_directory="$(setup_user_home "$user_name")"
nix_system="$(setup_nix_system)"

setup_enable_flakes
sudo -v
setup_create_host \
  "$repo_root" nixos "$host_name" "$user_name" "$home_directory" "$nix_system" "$hardware_source"

setup_log "the template inherits Nyx's GRUB device (/dev/sda); adjust hosts/$host_name/system.nix if needed"
setup_log "activating NixOS configuration $host_name"
sudo env "NIX_CONFIG=$NIX_CONFIG" nixos-rebuild switch --flake "path:$repo_root#$host_name"
setup_home_manager_switch "$repo_root" "$host_name"
setup_log "setup completed for $host_name"

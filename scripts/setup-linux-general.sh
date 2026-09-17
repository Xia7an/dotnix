#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/setup-host-common.sh
source "$script_directory/lib/setup-host-common.sh"

usage() {
  cat <<'EOF'
Usage: scripts/setup-linux-general.sh [HOST_NAME]

Installs Nix in single-user mode when needed, creates hosts/HOST_NAME from
template/linux-general, and activates Home Manager. If HOST_NAME is omitted,
the script prompts for it.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi
[[ $# -le 1 ]] || setup_die "usage: scripts/setup-linux-general.sh [HOST_NAME]"

setup_require_linux
[[ ! -e /etc/NIXOS && ! -e /run/current-system/nixos-version ]] \
  || setup_die "use scripts/setup-nixos.sh on NixOS"

repo_root="$(setup_repo_root)"
host_name="$(setup_host_name "${1:-}")"
user_name="$(setup_user_name)"
home_directory="$(setup_user_home "$user_name")"
nix_system="$(setup_nix_system)"

setup_install_nix
setup_enable_flakes
setup_create_host \
  "$repo_root" linux-general "$host_name" "$user_name" "$home_directory" "$nix_system"
setup_home_manager_switch "$repo_root" "$host_name"
setup_log "setup completed for $host_name"

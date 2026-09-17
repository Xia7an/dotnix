#!/usr/bin/env bash
set -euo pipefail

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib/setup-host-common.sh
source "$script_directory/lib/setup-host-common.sh"

usage() {
  cat <<'EOF'
Usage: scripts/setup-linux-general.sh [--desktop] [HOST_NAME]

Installs Nix in single-user mode when needed, creates hosts/HOST_NAME from
template/linux-general (or template/linux-general-desktop), and activates Home
Manager. If HOST_NAME is omitted, the script prompts for it.
EOF
}

desktop=false
host_name_argument=""
while (($# > 0)); do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    --desktop)
      desktop=true
      ;;
    --*)
      setup_die "unknown option: $1"
      ;;
    *)
      [[ -z "$host_name_argument" ]] || setup_die "host name specified more than once"
      host_name_argument="$1"
      ;;
  esac
  shift
done

template_name="linux-general"
$desktop && template_name="linux-general-desktop"

setup_require_linux
[[ ! -e /etc/NIXOS && ! -e /run/current-system/nixos-version ]] \
  || setup_die "use scripts/setup-nixos.sh on NixOS"

repo_root="$(setup_repo_root)"
host_name="$(setup_host_name "$host_name_argument")"
user_name="$(setup_user_name)"
home_directory="$(setup_user_home "$user_name")"
nix_system="$(setup_nix_system)"

setup_install_nix
setup_enable_flakes "$home_directory"
setup_create_host \
  "$repo_root" "$template_name" "$host_name" "$user_name" "$home_directory" "$nix_system"
setup_home_manager_switch "$repo_root" "$host_name"
setup_log "setup completed for $host_name"

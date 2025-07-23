# QEMU.nix
{ config, pkgs, lib, ... }:

let
  winIso = "../../misc/QEMU/Win11_24H2_Japanese_x64.iso"; # 自分でダウンロードして指定
  winDisk = "/var/lib/libvirt/images/windows11.qcow2";
in {
  users.users.inoyu.extraGroups = with lib; [ "libvirtd" "kvm" ];

  environment.systemPackages = with pkgs; [
    virt-manager virt-viewer
    spice spice-gtk spice-protocol
    win-virtio win-spice
    dnsmasq
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  services.spice-vdagentd.enable = true;

  # VM定義
  virtualisation.libvirtd.extraStartVirtManagerArgs = "--no-fork";

  # 以下は libvirt XML 編集が必要なら追加で設定
  # nested virtualization なども調整可 :contentReference[oaicite:11]{index=11}
}


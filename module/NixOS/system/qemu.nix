# QEMU.nix
{ config, pkgs, lib, ... }:

let
  winIso = "../../misc/QEMU/Win11_24H2_Japanese_x64.iso"; # 自分でダウンロードして指定
  winDisk = "/var/lib/libvirt/images/windows11.qcow2";
in {
  users.users.inoyu.extraGroups = with lib; [ "libvirtd" "kvm" ];

  boot.kernelParams = [ "intel_iommu=on" "iommu=pt" ];
  boot.extraModprobeConfig = ''
    options vfio-pci ids=10de:128b,110de:0e0f
  '';
  boot.kernelModules = [ "vfio" "vfio_pci" "vfio_iommu_type1" "kvm" "kvm_intel" ]; # または "kvm_amd"


  environment.systemPackages = with pkgs; [
    qemu
    libvirt
    virt-manager 
    virt-viewer
    spice 
    spice-gtk 
    spice-protocol
    win-virtio 
    win-spice
    dnsmasq
    looking-glass-client
  ];

  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
      };
    };
    spiceUSBRedirection.enable = true;
  };

  services.spice-vdagentd.enable = true;

  # 以下は libvirt XML 編集が必要なら追加で設定
  # nested virtualization なども調整可 :contentReference[oaicite:11]{index=11}
}


# 仮のハードウェア設定。NixOS をインストールしたら、実機で生成したものに置き換える:
#   sudo nixos-generate-config --show-hardware-config > hosts/Odin/hardware.nix
# 置き換えるまでは下の assertion で nixos-rebuild が止まる (誤った設定で起動できなくなるのを防ぐ)。
{ lib, modulesPath, ... }:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  assertions = [
    {
      assertion = false;
      message = "hosts/Odin/hardware.nix は仮のファイルです。nixos-generate-config の出力に置き換えてください。";
    }
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault true;
}

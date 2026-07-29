{ pkgs, ... }:
{
  # Docker Desktop の代替。colima が VM 経由で lima/containerd を起動し、
  # docker.nix の docker CLI から colima の docker context 経由で利用する。
  #
  # stable の pkgs.lima は EOL バージョンで insecure 判定されビルド不可(colima も
  # 同じ lima 派生を介して連鎖的に評価失敗する)。両方 unstable から取る。
  home.packages = with pkgs.unstable; [
    colima
    lima
  ];
}

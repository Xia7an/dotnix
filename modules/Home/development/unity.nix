# Unity Hub のみを nix で導入する。
# Editor のインストールとバージョン管理は Unity Hub に任せる
# (プロジェクトの ProjectSettings/ProjectVersion.txt に従って Hub が導入を促す)。
# Hub から起動した Editor は Hub の FHS 環境内で動くため、必要なライブラリはそこで揃う。
{ pkgs, ... }:
{
  home.packages = [ pkgs.unityhub ];
}

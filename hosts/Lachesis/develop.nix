# Lachesis 用開発ツール設定
# IDE + CLIツール + コンテナ/仮想化
#
# 共通開発ツール (全プラットフォーム)
#   - general, git, direnv, rust, dev-tools, dev-apps, biome, lazygit
#   - colima, lima, qemu
#
# macOS 固有開発ツール
#   - cocoapods, xcode-install → module/Home/darwin/
{
  imports = [
    # ─── エディタ ───
    ../../module/Home/editor/neovim.nix
    ../../module/Home/editor/vscode.nix

    # ─── 開発ツール ───
    ../../module/Home/development/general.nix
    ../../module/Home/development/git.nix
    ../../module/Home/development/direnv.nix
    ../../module/Home/development/rust.nix
    ../../module/Home/development/dev-tools.nix
    ../../module/Home/development/cli-utils.nix
    ../../module/Home/development/dev-apps.nix
    ../../module/Home/development/biome.nix
    ../../module/Home/development/lazygit.nix
    ../../module/Home/development/llvm.nix
    ../../module/Home/development/java-dotnet.nix
    ../../module/Home/development/database.nix
    ../../module/Home/development/network.nix
    ../../module/Home/development/docker.nix

    # ─── コンテナ / 仮想化 ───
    ../../module/Home/development/colima.nix
    ../../module/Home/development/lima.nix
    ../../module/Home/development/qemu.nix

    # ─── macOS 固有開発ツール ───
    ../../module/Home/darwin/cocoapods.nix
    ../../module/Home/darwin/xcode-install.nix
  ];
}
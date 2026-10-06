{
  inputs,
  lib,
  pkgs,
  ...
}:

let
  chatgptPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.chatgpt;
in
{
  # GUI を使うホストでは CLI も導入する。認証・設定・履歴は通常の ~/.codex を使う。
  imports = [ ./codex.nix ];

  home.packages = [
    (
      if pkgs.stdenv.hostPlatform.isDarwin then
        # 署名・Keychain 権限・自己更新を保つため、本体は nix-darwin の cask で管理。
        pkgs.writeShellApplication {
          name = "chatgpt";
          text = ''
            exec /usr/bin/open -b com.openai.codex --args "$@"
          '';
        }
      else
        # 公式 Linux preview の Nix パッケージ。デスクトップエントリと
        # ダウンロードされる runtime の NixOS 向けパッチも上流で提供される。
        chatgptPackage
    )
  ];

  # アプリ一覧からの起動にも runtime パッチ付きラッパーを使う。
  # GUI セッションの PATH や deb 由来の /usr/lib 配置には依存させない。
  xdg.desktopEntries.chatgpt = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
    name = "ChatGPT";
    comment = "ChatGPT and Codex desktop app";
    exec = "${lib.getExe chatgptPackage} %U";
    icon = "chatgpt";
    terminal = false;
    categories = [
      "Development"
      "Office"
    ];
  };
}

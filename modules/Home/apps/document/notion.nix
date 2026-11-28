{ ... }: {
  # notion-app-enhanced は古い Electron のため Notion 側で非対応と弾かれる。
  # Linux 向けの公式クライアントは nixpkgs に無いので、Chrome のアプリモードで開く。
  xdg.desktopEntries.notion = {
    name = "Notion";
    exec = "google-chrome-stable --app=https://www.notion.so";
    icon = "notion";
    categories = [ "Office" ];
    settings.StartupWMClass = "chrome-www.notion.so__-Default";
  };
}

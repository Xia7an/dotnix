{ inputs }:
[
  (import inputs.rust-overlay)

  (
    final: _prev:
    let
      unstable = import inputs.nixpkgs-unstable {
        system = final.stdenv.hostPlatform.system;
        config.allowUnfree = true;
      };
    in
    {
      inherit (unstable)
        blender
        discord
        google-chrome
        neovim
        nextcloud-client
        noctalia
        obsidian
        opencode
        rstudio
        slack
        vivaldi
        vscode
        vscode-extensions
        vscode-utils
        zed-editor
        ;
    }
  )

  (final: prev: {
    niri-taskbar = prev.callPackage ../pkgs/niri-taskbar { };
  })
]

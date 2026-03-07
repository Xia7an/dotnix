{ config, lib, pkgs, ... }:

let
  cfg = config.dotnix.develop.unity;
  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    findFirst
    mkIf
    mkOption
    optional
    optionalString
    types;

  selectedUser =
    if cfg.user != null then cfg.user else
    if config.services.displayManager.autoLogin.enable or false then config.services.displayManager.autoLogin.user else
    null;

  selectedHomeDirectory =
    if cfg.homeDirectory != null then cfg.homeDirectory else
    if selectedUser != null then "/home/${selectedUser}" else
    null;

  escapeForDoubleQuotedShell =
    value:
    lib.replaceStrings [ "\\" ''"'' "`" ] [ "\\\\" ''\\"'' "\\`" ] value;

  sanitizeVersion = version: lib.replaceStrings [ "." " " "/" ":" ] [ "-" "-" "-" "-" ] version;

  editorCommandName =
    editor:
    if editor.command != null then editor.command else "unity-editor-${sanitizeVersion editor.version}";

  editorBinaryExpression =
    editor:
    ''"${escapeForDoubleQuotedShell cfg.installPath}/${editor.version}/Editor/Unity"'';

  moduleArgs = modules: concatMapStringsSep " " (moduleName: "--module ${escapeShellArg moduleName}") modules;

  installArgs =
    editor:
    concatMapStringsSep " " (arg: arg) (
      [
        "--version ${escapeShellArg editor.version}"
        "--changeset ${escapeShellArg editor.changeset}"
      ]
      ++ optional (editor.modules != [ ]) (moduleArgs editor.modules)
      ++ optional editor.childModules "--childModules"
    );

  installModuleArgs =
    editor:
    concatMapStringsSep " " (arg: arg) (
      [ "--version ${escapeShellArg editor.version}" ]
      ++ optional (editor.modules != [ ]) (moduleArgs editor.modules)
      ++ optional editor.childModules "--childModules"
    );

  makeEditorLauncher =
    packageName: editor:
    pkgs.writeShellApplication {
      name = packageName;
      runtimeInputs = [ pkgs.unityhub-shell ];
      text = ''
        set -euo pipefail

        editor_path=${editorBinaryExpression editor}

        if [ ! -x "$editor_path" ]; then
          echo "Unity Editor not found: $editor_path" >&2
          echo "Run: sudo systemctl start unity-editor-sync.service" >&2
          exit 1
        fi

        if [ "$#" -gt 0 ] && [ -d "$1" ]; then
          project_path="$1"
          shift
          exec unityhub-shell "$editor_path" -projectPath "$project_path" "$@"
        fi

        exec unityhub-shell "$editor_path" "$@"
      '';
    };

  declaredEditorPackages = map (editor: makeEditorLauncher (editorCommandName editor) editor) cfg.editors;

  selectedDefaultEditor =
    if cfg.defaultEditor == null then
      if cfg.editors == [ ] then null else builtins.head cfg.editors
    else
      findFirst
        (editor: editor.version == cfg.defaultEditor || editorCommandName editor == cfg.defaultEditor)
        null
        cfg.editors;

  defaultEditorPackage =
    if selectedDefaultEditor == null then
      null
    else
      makeEditorLauncher "unity-editor" selectedDefaultEditor;

  syncScript = pkgs.writeShellApplication {
    name = "unity-editor-sync";
    runtimeInputs = [ pkgs.unityhub pkgs.coreutils ];
    text = ''
      set -euo pipefail

      log() { echo "[unity-editor-sync] $(date '+%Y-%m-%d %H:%M:%S') $*"; }

      ${optionalString (selectedHomeDirectory != null) "export HOME=${escapeShellArg selectedHomeDirectory}"}
      export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
      install_path="${escapeForDoubleQuotedShell cfg.installPath}"

      log "Install path: $install_path"
      mkdir -p "$install_path"

      log "Setting Unity Hub install path..."
      unityhub --headless install-path --set "$install_path"

      ${concatMapStringsSep "\n\n" (editor: ''
        if [ ! -x "$install_path/${editor.version}/Editor/Unity" ]; then
          log "Installing Unity Editor ${editor.version} (changeset ${editor.changeset})..."
          unityhub --headless install ${installArgs editor}
          log "Unity Editor ${editor.version} installation complete."
        else
          log "Unity Editor ${editor.version} already installed — skipping."
          ${optionalString (editor.modules != [ ]) ''
            log "Ensuring modules for ${editor.version}: ${concatMapStringsSep ", " (m: m) editor.modules}"
            unityhub --headless install-modules ${installModuleArgs editor}
          ''}
        fi
      '') cfg.editors}

      log "All editors synchronized."
    '';
    meta.mainProgram = "unity-editor-sync";
  };
in
{
  options.dotnix.develop.unity = {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable the Unity development environment.";
    };

    user = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "inoyu";
      description = "User account that owns the Unity Hub configuration and editor installs. Defaults to the display manager autologin user when available.";
    };

    homeDirectory = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/home/inoyu";
      description = "Home directory used for headless Unity Hub installation state. Defaults to `/home/<user>`.";
    };

    installPath = mkOption {
      type = types.str;
      default = "$HOME/Unity/Hub/Editor";
      description = "Directory where Unity Hub should install and track editor versions.";
    };

    defaultEditor = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "6000.1.9f1";
      description = "Default editor version or generated command name used for the `unity-editor` wrapper.";
    };

    editors = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            version = mkOption {
              type = types.str;
              example = "6000.1.9f1";
              description = "Unity Editor version identifier.";
            };

            changeset = mkOption {
              type = types.str;
              example = "ed7b183fd33d";
              description = "Unity changeset required by the Hub CLI for deterministic installation.";
            };

            modules = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [ "android" "android-sdk-ndk-tools" "android-open-jdk" ];
              description = "Optional Unity modules to install declaratively with this editor.";
            };

            childModules = mkOption {
              type = types.bool;
              default = true;
              description = "Whether Hub should also install child modules for the declared module set.";
            };

            command = mkOption {
              type = types.nullOr types.str;
              default = null;
              example = "unity-6000-lts";
              description = "Optional custom command name. Defaults to `unity-editor-<version>`.";
            };
          };
        }
      );
      # ---------------------------------------------------------------
      # 管理するエディターはここで宣言する。
      # changeset は https://unity.com/releases/editor/whats-new/<version>
      # のページ冒頭 "Changeset:" 欄で確認できる。
      # ---------------------------------------------------------------
      default = [
        {
          version = "6000.1.9f1"; # Unity 6 LTS
          changeset = "ed7b183fd33d";
          # Androidビルドサポートが必要な場合は以下のコメントを外す:
          # modules = [ "android" "android-sdk-ndk-tools" "android-open-jdk" ];
        }
        {
          version = "6000.2.6f2";
          changeset = "4a4dcaec6541";
        }
      ];
      description = "Unity Editors that should be installed and kept in sync by Unity Hub's headless CLI.";
    };

    extraPackages = mkOption {
      type = types.listOf types.package;
      default = [ ];
      description = "Additional packages to install alongside Unity Hub and the generated editor wrappers.";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages =
      [
        pkgs.unityhub
        pkgs.unityhub-shell
        syncScript
      ]
      ++ declaredEditorPackages
      ++ optional (defaultEditorPackage != null) defaultEditorPackage
      ++ cfg.extraPackages;

    environment.etc."unity/editors.json".text = builtins.toJSON {
      installPath = cfg.installPath;
      defaultEditor = cfg.defaultEditor;
      user = selectedUser;
      homeDirectory = selectedHomeDirectory;
      editors = map (editor: {
        inherit (editor) version changeset modules childModules command;
        launcher = editorCommandName editor;
      }) cfg.editors;
    };

    environment.sessionVariables = {
      UNITY_DECLARED_EDITOR_COMMANDS = concatMapStringsSep ":" editorCommandName cfg.editors;
      UNITY_EDITOR_ROOT = cfg.installPath;
    };

    systemd.services.unity-editor-sync = mkIf (cfg.editors != [ ]) {
      description = "Synchronize declarative Unity Editor installs";
      # NOT added to wantedBy — do not auto-start at boot.
      # Running at boot blocks the entire boot sequence because this service
      # waits for network-online.target (WiFi), which can hang indefinitely.
      # Trigger manually after nixos-rebuild:
      #   sudo systemctl start unity-editor-sync
      # Monitor progress:
      #   journalctl -u unity-editor-sync -f
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        # RemainAfterExit は意図的に設定しない。
        # "yes" にすると完了後も "active" 状態が残り、次回 nixos-rebuild switch で
        # ユニットファイルが変化したと判断されたときに switch-to-configuration が
        # 再起動を試みる。network-online.target(WiFi) 待ちと TimeoutStartSec=infinity
        # の組み合わせで rebuild が無限にフリーズする原因になる。
        # "inactive (dead)" のままにしておくことで switch-to-configuration はスキップする。
        TimeoutStartSec = "infinity";
        User = selectedUser;
        WorkingDirectory = selectedHomeDirectory;
        StandardOutput = "journal+console";
        StandardError = "journal+console";
      };
      environment = {
        HOME = selectedHomeDirectory;
        XDG_CONFIG_HOME = "${selectedHomeDirectory}/.config";
      };
      script = ''
        exec ${syncScript}/bin/unity-editor-sync
      '';
    };

    assertions = [
      {
        assertion = builtins.hasAttr "unityhub-shell" pkgs;
        message = "`pkgs.unityhub-shell` is required. Ensure the overlay in `overlays/default.nix` is loaded.";
      }
      {
        assertion = cfg.defaultEditor == null || selectedDefaultEditor != null;
        message = "`dotnix.develop.unity.defaultEditor` must match a declared editor version or command.";
      }
      {
        assertion = cfg.editors == [ ] || (selectedUser != null && selectedHomeDirectory != null);
        message = "Declare `dotnix.develop.unity.user` (or enable display manager autologin) so Unity Hub can install editors declaratively.";
      }
    ];
  };
}

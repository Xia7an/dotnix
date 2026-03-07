final: prev: {
  niri-taskbar = prev.callPackage ../pkgs/niri-taskbar { };
  
  # Unity Hub Workaround: https://github.com/nixos/nixpkgs/issues/419634
  gnome2 = prev.gnome2 // {
    GConf = final.emptyDirectory;
  };
  unityhub = prev.unityhub.override {
    extraLibs = (unityhubPkgs: [
      (unityhubPkgs.runCommand "libxml2-fake-old-abi" {} ''
        mkdir -p "$out/lib"
        ln -s "${unityhubPkgs.lib.getLib unityhubPkgs.libxml2}/lib/libxml2.so" "$out/lib/libxml2.so.2"
      '')
    ]);
  };

  unityhub-shell = prev.buildFHSEnv {
    name = "unityhub-shell";
    targetPkgs = p: with p; [
      unityhub
      fontconfig
      freetype
      gsettings-desktop-schemas
      hicolor-icon-theme
      lsb-release
      xdg-utils
      xorg.libXrandr
      fcitx5
      fcitx5-gtk
      libsForQt5.fcitx5-qt
    ];
    multiPkgs = p: with p; [
      alsa-lib
      at-spi2-core
      atk
      cairo
      clang
      cpio
      cups
      dbus
      expat
      gdk-pixbuf
      git
      glib
      gnome2.GConf
      gtk3
      harfbuzz
      icu
      krb5
      libappindicator
      libcap
      libdrm
      libgbm
      libglvnd
      libnotify
      libpulseaudio
      libsecret
      libuuid
      libva
      libxkbcommon
      libxml2
      lttng-ust_2_12
      nspr
      nss
      openssl
      pango
      udev
      vulkan-loader
      wayland
      xorg.libX11
      xorg.libXScrnSaver
      xorg.libXcomposite
      xorg.libXcursor
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXi
      xorg.libXrender
      xorg.libXtst
      xorg.libxcb
      xorg.libxshmfence
      zlib
      # Workaround for libxml2.so.2
      (p.runCommand "libxml2-fake-abi" { } ''
        mkdir -p $out/lib
        ln -s "${p.lib.getLib p.libxml2}/lib/libxml2.so" $out/lib/libxml2.so.2
      '')
    ];
    profile = ''
      export LD_LIBRARY_PATH=/usr/lib:$LD_LIBRARY_PATH
      export GTK_IM_MODULE=fcitx
      export QT_IM_MODULE=fcitx
      export XMODIFIERS=@im=fcitx
      export QT_PLUGIN_PATH="${prev.libsForQt5.fcitx5-qt}/lib/qt-5.15/plugins:$QT_PLUGIN_PATH"
    '';
    # With the default runScript = "bash", calling `unityhub-shell /path/to/binary arg`
    # would run `bash /path/to/binary arg` — treating the Unity ELF binary as a shell
    # script, which fails immediately. This runScript forwards all arguments to exec
    # directly so that launcher wrappers can call:
    #   exec unityhub-shell "$editor_path" "$@"
    runScript = prev.writeShellScript "unity-shell-run" ''
      if [ "$#" -gt 0 ]; then
        exec "$@"
      else
        exec ${prev.bash}/bin/bash
      fi
    '';
  };
}

{pkgs, ...}: {
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5.addons = with pkgs; [
      fcitx5-mozc
      fcitx5-gtk
    ];
  };
  i18n.inputMethod.fcitx5.waylandFrontend = true;
  i18n.inputMethod.fcitx5.settings.inputMethod = {
    "Groups/0" = {
      "Name" = "Default";
      "Default Layout" = "jp";
      "DefaultIM" = "mozc";
    };
    "Groups/0/Items/0".Name = "keyboard-jp";
    "Groups/0/Items/1".Name = "mozc";
  };
}


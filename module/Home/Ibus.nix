{pkgs, ...} : {
  i18n.inputMethod = {
    ibus.engines = with pkgs.ibus-engines; [
      mozc-ut
    ];
  };
}

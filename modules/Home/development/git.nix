{pkgs, ...}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Inoyu";
        email = "inoyu0329@gmail.com";
      };
    };
  };
}

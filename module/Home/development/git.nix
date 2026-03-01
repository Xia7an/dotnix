{pkgs, ...}: {
  programs.git = {
    enable = true;
    userName = "Inoyu";
    userEmail = "inoyu0329@gmail.com";
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    extensions = with pkgs; [gh-markdown-preview]; # オススメ
    settings = {
      editor = "nvim";
    };
  };
}

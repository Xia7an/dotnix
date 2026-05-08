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

  # GitHub CLI
  programs.gh = {
    enable = true;
    extensions = with pkgs; [gh-markdown-preview]; # オススメ
    settings = {
      editor = "nvim";
      git_protocol = "https";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };
}

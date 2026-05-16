{pkgs, ...}: {
  programs.gh = {
    enable = true;
    extensions = with pkgs; [gh-markdown-preview];
    settings = {
      editor = "nvim";
      git_protocol = "https";
      prompt = "enabled";
      aliases = {
        co = "pr checkout";
      };
    };
  };

  home.packages = with pkgs; [
    ghq
    fzf
  ];

  programs.git.settings.ghq.root = "~/Gits";

  programs.fish.shellInit = ''
    function peco_src
        set -l query (commandline)
        set -l selected_dir (ghq list -p | fzf --prompt="repositories >" --query "$query")
        if test -n "$selected_dir"
            commandline "cd $selected_dir"
            commandline -f execute
        end
        commandline -f repaint
    end
    bind \c] peco_src
  '';
}

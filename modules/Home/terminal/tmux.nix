{ config, pkgs, ... }:
let
  statusRightScript = ''
    #{prefix_highlight}#[fg=colour111, bg=colour238]\
    #[fg=brightwhite, bg=colour111, bold] #{battery_percentage}%\
    #[fg=colour238, bg=colour111] \
    #[fg=colour111, bg=colour238]\
    #[fg=brightwhite, bg=colour111, bold]#(curl -s ifconfig.me)\
    #[fg=colour238, bg=colour111] \
    #[fg=colour111, bg=colour238]\
    #[fg=brightwhite, bg=colour111]#(ifconfig en0 | grep "inet " | awk '{print $2}')
  '';
in
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    terminal = "screen-256color";

    plugins = with pkgs.tmuxPlugins; [
      # Battery status
      {
        plugin = battery;
        extraConfig = ''
          set -g @batt_icon_status_charged ' '
          set -g @batt_icon_status_charging '⚡ '
        '';
      }
      # Online status indicator
      online-status
      # Prefix highlight
      {
        plugin = prefix-highlight;
        extraConfig = ''
          set -g @prefix_highlight_fg 'colour111'
          set -g @prefix_highlight_bg 'colour238'
        '';
      }
    ];

    extraConfig = ''
      # ── Vim-style pane navigation (no prefix) ──
      bind -n C-h select-pane -L
      bind -n C-j select-pane -D
      bind -n C-k select-pane -U
      bind -n C-l select-pane -R

      # ── Alt-arrow pane navigation (no prefix) ──
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # ── Resize panes with prefix + H/J/K/L ──
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # ── Window switching ──
      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # ── Splits with current path ──
      bind | split-window -h -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      # ── Renumber windows on close ──
      set -g renumber-windows on
      set -g pane-base-index 1

      # ── Message styling ──
      set -g message-style fg=colour68,reverse,bg=brightwhite

      # ── Pane border styling ──
      set -g pane-active-border-style fg=colour111,bg=default
      set -g pane-border-style fg=colour111,bg=default

      # ── Transparent window background ──
      set -g window-style bg=default
      set -g window-active-style bg=default

      # ── Status bar ──
      set -g status-position top
      set -g status-interval 1
      set -g status-left-length 90
      set -g status-right-length 90
      set -g status-fg 'brightwhite'
      set -g status-bg 'colour238'
      set -g status-left '#[fg=brightwhite, bg=colour111, bold] #S #[fg=colour111, bg=colour238]'
      set -g status-right '${statusRightScript}'
      setw -g window-status-separator ""
      set -g status-justify left

      # ── Copy-mode VI ──
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection

      # ── Popup ──
      bind -n C-q run-shell "fish -c 'tmux popup'"

      # ── Reload ──
      bind r source-file ~/.config/tmux/tmux.conf \; display-message 'Reloaded.'
    '';
  };
}

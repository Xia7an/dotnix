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
      # ── Prefix + vim keys to navigate panes ──
      bind -r h select-pane -L
      bind -r j select-pane -D
      bind -r k select-pane -U
      bind -r l select-pane -R

      # ── Prefix + vim keys (capital) to resize panes ──
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D
      bind -r K resize-pane -U
      bind -r L resize-pane -R 5

      # ── Copy-mode vi ──
      setw -g mode-keys vi
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi C-v send -X rectangle-toggle
      bind -T copy-mode-vi y send -X copy-selection

      # ── Window switching ──
      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # ── Splits with current path ──
      bind | split-window -h -c '#{pane_current_path}'
      bind - split-window -v -c '#{pane_current_path}'

      # ── Popup ──
      bind -n C-q run-shell "tmux display-popup; true"

      # ── Switch panes using Alt-arrow without prefix ──
      bind -n M-Left select-pane -L
      bind -n M-Right select-pane -R
      bind -n M-Up select-pane -U
      bind -n M-Down select-pane -D

      # ── Reload ──
      bind-key -T prefix r source-file ~/.config/tmux/tmux.conf \; display-message 'Reloaded.'

      # ── Renumber windows on close ──
      set -g renumber-windows on
      setw -g pane-base-index 1

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
    '';
  };
}

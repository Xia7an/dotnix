# hyprland.nix
{ pkgs, ... }:

{
  # この設定で使われているプログラムをインストールします。
  # dolphin, walker, wlogout, rofi-screenshot(パッケージ名による), ydotool など、
  # 不足しているものがあればここに追加してください。
  home.packages = with pkgs; [
    waybar
    hyprpaper
    hyprpicker
    hyprpolkitagent
    # ydotool は特別な設定が必要な場合があります
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    # Hyprlandのプラグインを使用している場合、ここに追加します
    # 例: plugins = [ pkgs.hyprland-plugins.hyprexpo ];
    plugins = [
      pkgs.hyprlandPlugins.hyprbars
    ];

    settings = {
      #================================#
      # Monitors
      #================================#
      monitor = [
        ",preferred,auto,auto"
        "HDMI-A-1, preferred, 0x0, 1"
        "DVI-D-1, preferred, 2560x0, 1"
      ];

      #================================#
      # My Programs
      #================================#
      "$terminal" = "kitty";
      "$fileManager" = "dolphin";
      "$menu" = "walker --modules applications";

      #================================#
      # Autostart
      #================================#
      exec-once = [
        "waybar"
        "hyprpaper"
        "sunshine"
        "fcitx5"
        "swaync"
        "hyprpm reload -n"
      ];

      #================================#
      # Environment Variables
      #================================#
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
        "ELECTRON_OZONE_PLATFORM_HINT,auto"
      ];

      #================================#
      # Plugins
      #================================#
      plugin = {
        hyprexpo = {
          columns = 3;
          gap_size = 5;
          bg_col = "rgb(111111)";
          workspace_method = "center current";
          enable_gesture = true;
          gesture_fingers = 3;
          gesture_distance = 300;
          gesture_positive = true;
        };
        hyprbars = {
          bar_height = 24;
          bar_color = "rgba(333333ff)";
          bar_blur = true;
          bar_precedence_over_border = false;
          bar_buttons_alignment = "left";
          bar_button_padding = 4;
          bar_text_font = "Rounded Mgen+ 2m";
          bar_text_size = 14;
          col.text = "rgb(94abcc)";
          bar_part_of_window = false;
          #"hyprbars-button" = [
          #  "rgb(ff4040), 16, 󰖭, hyprctl dispatch killactive, rgb(ffffff)"
          #  "rgb(11ee33), 16, , hyprctl dispatch fullscreen, rgb(ffffff)"
          #  "rgb(eeee11), 16, , hyprctl dispatch fullscreen 1, rgb(ffffff)"
          #];
        };
      };

      #================================#
      # Look and Feel
      #================================#
      general = {
        gaps_in = 5;
        gaps_out = 15;
        border_size = 4;
        "col.active_border" = "rgba(c9ecf4ee) rgba(0342abee)";
        "col.inactive_border" = "rgba(595959ee)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        shadow = {
          enabled = true;
          range = 4;
          render_power = 3;
          color = "rgba(1a1a1aee)";
        };
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
          vibrancy = 0.1696;
        };
      };

      animations = {
        enabled = "yes";
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      master = {
        new_status = "master";
      };

      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = false;
      };

      #================================#
      # Window and Layer Rules
      #================================#
      windowrule = [
        "opacity 0.85, class:kitty"
        "opacity 0.85, class:rofi"
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
      layerrule = [
        "blur, swaync-control-center"
      ];

      #================================#
      # Input
      #================================#
      input = {
        kb_layout = "jp";
        kb_model = "jp106";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = false;
        };
      };

      gestures = {
        workspace_swipe = false;
      };


      #================================#
      # Keybindings
      #================================#
      "$mainMod" = "SUPER";

      bind = [
        "$mainMod, return, exec, $terminal"
        "$mainMod, Q, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, space, exec, $menu"
        "$mainMod, F, fullscreen"
        "$mainMod, W, exec, wlogout"
        "$mainMod CTRL, S, exec, rofi-screenshot"
        "$mainMod, N, exec, swaync-client -t"
        
        # Move focus
        "$mainMod, left, movefocus, l"
        "$mainMod, right, movefocus, r"
        "$mainMod, up, movefocus, u"
        "$mainMod, down, movefocus, d"
        "$mainMod, h, movefocus, l"
        "$mainMod, l, movefocus, r"
        "$mainMod, k, movefocus, u"
        "$mainMod, j, movefocus, d"
        
        # Move window
        "$mainMod SHIFT, right, movewindow, r"
        "$mainMod SHIFT, left, movewindow, l"
        "$mainMod SHIFT, up, movewindow, u"
        "$mainMod SHIFT, down, movewindow, d"
        "$mainMod SHIFT, l, movewindow, r"
        "$mainMod SHIFT, h, movewindow, l"
        "$mainMod SHIFT, k, movewindow, u"
        "$mainMod SHIFT, j, movewindow, d"
        
        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        
        # Move active window to a workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        
        # Special workspace
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        
        # Scroll through existing workspaces
        "$mainMod, mouse_down, workspace, e+1"
        "$mainMod, mouse_up, workspace, e-1"
      ];
      
      # Laptop multimedia keys
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];

      # Player control keys
      bindl = [
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
      ];

      # Variable for mousekb submap
      "$STEP" = 10;
    };

    #================================#
    # Submap (extraConfig)
    #================================#
    # `submap`は特殊な構文のため、extraConfigで直接記述するのが最も安全です。
    extraConfig = ''
      bind = LALT,SPACE,submap, mousekb
      submap = mousekb
      binde = , h, exec, sudo ydotool mousemove -- -$STEP 0
      binde = , j, exec, sudo ydotool mousemove -- 0 $STEP
      binde = , k, exec, sudo ydotool mousemove -- 0 -$STEP
      binde = , l, exec, sudo ydotool mousemove -- $STEP 0
      binde = LALT, j, exec, sudo ydotool click 0x40
      binde = LALT, k, exec, sudo ydotool click 0x80
      bind = , escape, submap, reset
      submap = reset
    '';
  };
  home.file.".config/waybar" = {
    source = ../../config/waybar;
    recursive = true;
  };
  home.file.".config/rofi" = {
    source = ../../config/rofi;
    recursive = true;
  };
  home.file.".config/swaync" = {
    source = ../../config/swaync;
    recursive = true;
  };
  home.file.".config/hypr/hyprpaper.conf" = {
    source = ../../config/hypr/hyprpaper.conf;
  };
  home.file.".config/hypr/shiroha.png" = {
    source = ../../config/hypr/shiroha.png;
  };
}

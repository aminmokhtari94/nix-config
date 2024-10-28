{ lib, config, pkgs, ... }:

with lib;
let
  cfg = config.default.desktop.wayland.hyprland;
in
{
  options.default.desktop.wayland.hyprland = with types; {
    enable = mkEnableOption "hyprland";

    autostart = mkOption {
      type = listOf str;
      default = [ ];
      description = "List of applications to start at hyprland startup";
    };
  };

  config = mkIf cfg.enable {

    home.packages = with pkgs; [
      wl-clipboard
      wtype

      # ScreenShot
      slurp
      grim
      grimblast

      swaybg
      neofetch
      libnotify
      playerctl
    ];

    programs.wofi.enable = true;
    services.playerctld.enable = true;
    services.cliphist.enable = true;

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-gtk";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      settings = {
        exec-once = [
          "hyprctl setcursor Bibata-Modern-Ice 22"
          "[workspace 2 silent] floorp"
          "kitty"
        ] ++ (map (m: "swaybg --output ${m.name} --image ${m.wallpaper} --mode fill") config.monitors)
        ++ cfg.autostart;

        workspace = lib.lists.flatten (map
          (m:
            map (w: "${w}, monitor:${m.name}") (m.workspaces)
          )
          (config.monitors));

        env = [
          "XCURSOR_SIZE,24"
          "XDG_CURRENT_DESKTOP,Hyprland"
          "XDG_SESSION_TYPE,wayland"
          "XDG_SESSION_DESKTOP,Hyprland"
          "QT_QPA_PLATFORM,wayland;xcb"
          "QT_QPA_PLATFORMTHEME,qt6ct"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
          "QT_AUTO_SCREEN_SCALE_FACTOR,1"
          "MOZ_ENABLE_WAYLAND,1"
          "GDK_SCALE,1"
          "GDK_BACKEND,wayland,x11"
        ];

        general = {
          gaps_in = 2;
          gaps_out = 6;
          border_size = 2;
          "col.active_border" = "rgb(F48FB1) rgb(78A8FF) 45deg";
          "col.inactive_border" = "rgba(585272aa)";
          layout = "dwindle";
          resize_on_border = true;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        master = {
          orientation = "master";
        };

        decoration = {
          rounding = 5;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
            new_optimizations = true;
          };
          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
        };

        group = {
          "col.border_active" = "rgba(63F2F1aa)";
          "col.border_inactive" = "rgba(585272aa)";

          groupbar = {
            font_family = "Iosevka";
            font_size = 13;
            "col.active" = "rgba(63F2F1aa)";
            "col.inactive" = "rgba(585272aa)";
          };
        };

        misc = {
          disable_hyprland_logo = true;
          disable_splash_rendering = true;
	  mouse_move_enables_dpms = true;
	  key_press_enables_dpms = true;
        };

        xwayland = {
          force_zero_scaling = true;
        };

        input = {
          kb_layout = "us,ir";
          kb_variant = config.keyboard.variant;
          kb_options = config.keyboard.options;
          sensitivity = 0.15;
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
            drag_lock = true;
          };
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_distance = 200;
          workspace_swipe_forever = true;
        };

        device = [
          {
            name = "getech-huge-trackball-1";
            "scroll_method" = "on_button_down";
            "scroll_button" = 279;
            "natural_scroll" = true;
          }
          {
            name = "ploopy-corporation-ploopy-adept-trackball-mouse";
            natural_scroll = true;
          }
        ];

        monitor = map
          (m:
            let
              resolution = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
              position = "${toString m.x}x${toString m.y}";
            in
            "${m.name},${if m.enabled then "${resolution},${position},${toString m.scale}" else "disable"}"
          )
          (config.monitors);

        animations = {
          enabled = true;
          bezier = [
            "overshot,0.05,0.9,0.1,1.1"
            "overshot,0.13,0.99,0.29,1."
          ];
          animation = [
            "windows,1,7,overshot,slide"
            "border,1,10,default"
            "fade,1,10,default"
            "workspaces,1,7,overshot,slidevert"
          ];
        };

        windowrulev2 = [
          "workspace 1,class:kitty"
          "workspace 2,title:^(Mozilla Firefox)(.*)$"
          "workspace 2,class:floorp"
          "workspace special:notes,title:^(kitty-default)"
          "workspace special:term,title:^(kitty-scratch)"
          "workspace 3,class:Slack"
          "workspace 3,class:WebCord"
          "float,title:(GnuCash Tip Of The Day)"
          "float,title:(Firefox — Sharing Indicator)"
          "float,title:(Floorp — Sharing Indicator)"
          "float,title:galculator"
          "float,title:kitty-float"
        ];

        "$mainMod" = "SUPER";
        bind = [
          "$mainMod, Return, exec, kitty"
          "$mainMod, q, killactive,"
          "$mainMod SHIFT, q, exit,"
          "$mainMod SHIFT, b, exec, ${pkgs.killall}/bin/killall -SIGUSR1 .waybar-wrapped"
          "$mainMod, f, fullscreen, 0"
          "$mainMod, m, fullscreen, 1"
          "$mainMod SHIFT, t, togglefloating,"
          "$mainMod, d, exec, wofi --show drun -I"
          "ALT, e, exec, wofi-emoji"

          "$mainMod, r, exec, kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=1c --hold"
          "$mainMod CTRL, r, exec, kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=40c --hold"
          "$mainMod, o, exec, kitty --title='kitty-float' --override initial_window_width=150c --override initial_window_height=42c zsh -ic 'zk edit --interactive'"
          "$mainMod, e, exec, kitty --title='kitty-float' --override initial_window_width=80c --override initial_window_height=20c qke"

          "$mainMod, n, exec, nautilus"
          "$mainMod, t, exec, telegram-desktop"
          "$mainMod, P, pseudo, # dwindle"
          "$mainMod, s, togglespecialworkspace, notes"
          "$mainMod SHIFT, S, movetoworkspace, special:notes"
          "$mainMod CTRL, t, togglespecialworkspace, term"
          "$mainMod, g, togglegroup"
          "$mainMod, TAB, changegroupactive, f"
          "$mainMod SHIFT, TAB, changegroupactive, b"
          "$mainMod, z, focuswindow, title:kitty-journal"
          "$mainMod, period, exec, zsh -c 'wl-paste >> $JOURNALS/$(date +%Y-%m-%d).md && notify-send \"pasted into $(date +%Y-%m-%d).md!\"'"
          "$mainMod, v, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"

          "$mainMod CTRL, h, workspace, r-1"
          "$mainMod CTRL, l, workspace, r+1"
          "$mainMod CTRL SHIFT, h, movetoworkspace, r-1"
          "$mainMod CTRL SHIFT, l, movetoworkspace, r+1"

          #"$mainMod CTRL, k, swapwindow, u"
          #"$mainMod CTRL, j, swapwindow, d"

          "$mainMod ALT, h, moveintogroup, l"
          "$mainMod ALT, l, moveintogroup, r"
          "$mainMod ALT, k, moveintogroup, u"
          "$mainMod ALT, j, moveintogroup, d"

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

          ", XF86AudioLowerVolume, exec, pactl -- set-sink-volume 0 -10%"
          ", XF86AudioRaiseVolume, exec, pactl -- set-sink-volume 0 +10%"
          ", XF86AudioMute, exec, pactl -- set-sink-mute 0 toggle"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86Calculator, exec, gnome-calculator"
          "$mainMod, KP_ENTER, exec, gnome-calculator"

          ", XF86MonBrightnessDown, exec, ${pkgs.brightnessctl}/bin/brightnessctl set 10-"
          ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +10"
          ", XF86MonBrightnessUp, exec, ${pkgs.brightnessctl}/bin/brightnessctl set +10"

          "$mainMod, bracketright, focusmonitor, r"
          "$mainMod, bracketleft, focusmonitor, l"

          ", Pause, exec, hyprlock"
          "$mainMod ALT CTRL, equal, exec, dunstctl set-paused toggle"
          "$mainMod ALT CTRL, bracketright, exec, systemctl reboot"

          "CTRL, Print, exec, grimblast copy area"
          "CTRL SHIFT, Print, exec, grimblast save area"
          "ALT CTRL SHIFT, Print, exec, grimblast copy active"
          ", Print, exec, grimblast copy output"
        ];

        bindm = [
          "$mainMod, mouse:272, movewindow"
          "$mainMod, mouse:273, resizewindow"
        ];
        };
    };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.default.desktop.wayland.niri;
  theme = config.default.theme;
  p = theme.palette;

  kdlString = value: "\"${replaceStrings ["\\" "\"" "\n"] ["\\\\" "\\\"" "\\n"] (toString value)}\"";

  transformName = transform: let
    transforms = {
      "0" = "normal";
      "1" = "90";
      "2" = "180";
      "3" = "270";
      "4" = "flipped";
      "5" = "flipped-90";
      "6" = "flipped-180";
      "7" = "flipped-270";
    };
  in
    transforms.${toString transform} or (toString transform);

  outputConfig = m: ''
    output ${kdlString m.name} {
        ${
      if m.enabled
      then ''
        mode ${kdlString "${toString m.width}x${toString m.height}@${toString m.refreshRate}"}
        scale ${m.scale}
        transform ${kdlString (transformName m.transform)}
        position x=${toString m.x} y=${toString m.y}
      ''
      else "off"
    }
    }
  '';

  startupCommands =
    (optionals (config.monitors != []) [
      "swaybg -i ${(head config.monitors).wallpaper} -m fill"
    ])
    ++ [
      "kitty"
    ]
    ++ cfg.autostart;

  startupConfig = concatMapStringsSep "\n" (cmd: "spawn-sh-at-startup ${kdlString cmd}") startupCommands;

  workspaceConfig = concatMapStringsSep "\n" (workspace: "workspace ${kdlString workspace}") [
    "notes"
    "term"
  ];
in {
  options.default.desktop.wayland.niri = with types; {
    enable = mkEnableOption "niri";

    autostart = mkOption {
      type = listOf str;
      default = [];
      description = "List of shell commands to start at niri startup";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      wl-clipboard
      wtype

      swaybg
      swaylock
      xwayland-satellite

      fastfetch
      libnotify
      playerctl
      pavucontrol
      brightnessctl
    ];

    services.playerctld.enable = true;
    services.cliphist.enable = true;

    xdg.configFile."niri/config.kdl" = {
      force = true;
      text = ''
        input {
            keyboard {
                xkb {
                    layout "us,ir"
                    variant ${kdlString config.keyboard.variant}
                    options ${kdlString config.keyboard.options}
                }

                numlock
            }

            touchpad {
                tap
                drag-lock
                natural-scroll
            }

            mouse {
                accel-speed 0.15
            }

            trackball {
                natural-scroll
            }

            focus-follows-mouse
            workspace-auto-back-and-forth
            mod-key "Super"
        }

        ${concatMapStringsSep "\n" outputConfig config.monitors}

        ${workspaceConfig}

        layout {
            gaps 4
            center-focused-column "on-overflow"
            always-center-single-column
            background-color "#${p.bg}"

            preset-column-widths {
                proportion 0.33333
                proportion 0.5
                proportion 0.66667
                proportion 1.0
            }

            default-column-width { proportion 0.5; }

            focus-ring {
                off
            }

            border {
                width 1.5
                active-gradient from="#${p.accent}" to="#${p.accent2}" angle=45 relative-to="workspace-view"
                inactive-color "#${p.surfaceAlt}aa"
                urgent-color "#${p.urgent}"
            }

            tab-indicator {
                hide-when-single-tab
                place-within-column
                gap 4
                width 2
                length total-proportion=1.0
                position "top"
                gaps-between-tabs 2
                corner-radius ${toString theme.rounding}
                active-gradient from="#${p.accent}" to="#${p.accent2}" angle=45 relative-to="workspace-view"
                inactive-color "#${p.surfaceAlt}aa"
                urgent-color "#${p.urgent}"
            }

            insert-hint {
                gradient from="#${p.accent}80" to="#${p.accent2}80" angle=45 relative-to="workspace-view"
            }

            struts {
                left 4
                right 4
                top 4
                bottom 4
            }
        }

        ${startupConfig}

        spawn-at-startup "xwayland-satellite"

        screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"
        prefer-no-csd

        window-rule {
            geometry-corner-radius ${toString theme.rounding}
            clip-to-geometry true
        }

        window-rule {
            match title="^kitty-float$"
            open-floating true
            default-column-width { fixed 1000; }
            default-window-height { fixed 560; }
        }

        window-rule {
            match app-id="firefox$" title="^Picture-in-Picture$"
            open-floating true
        }

        window-rule {
            match app-id="firefox$" title="^Library$"
            open-floating true
        }

        window-rule {
            match app-id="org.pulseaudio.pavucontrol"
            open-floating true
        }

        window-rule {
            match app-id="blueman-manager"
            open-floating true
        }

        window-rule {
            match app-id="nm-applet"
            open-floating true
        }

        window-rule {
            match app-id="nm-connection-editor"
            open-floating true
        }

        window-rule {
            match app-id="org.telegram.desktop"
            open-floating true
            default-column-width { fixed 500; }
            default-window-height { fixed 900; }
        }

        binds {
            Mod+Return { spawn "kitty"; }
            Mod+Q repeat=false { close-window; }
            Mod+Shift+Q { quit; }
            Mod+Shift+B { spawn-sh "${pkgs.procps}/bin/pkill -SIGUSR1 -x .waybar-wrapped || ${pkgs.procps}/bin/pkill -SIGUSR1 -x ironbar"; }
            Mod+F { fullscreen-window; }
            Mod+M { maximize-window-to-edges; }
            Mod+Shift+T { toggle-window-floating; }
            Mod+D { spawn "fuzzel"; }
            Alt+E { spawn "wofi-emoji"; }

            Mod+R { spawn-sh "kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=1c --hold"; }
            Mod+Ctrl+R { spawn-sh "kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=40c --hold"; }
            Mod+O { spawn-sh "kitty --title='kitty-float' --override initial_window_width=150c --override initial_window_height=42c zsh -ic 'zk edit --interactive'"; }
            Mod+E { spawn-sh "kitty --title='kitty-float' --override initial_window_width=80c --override initial_window_height=20c qke"; }

            Mod+N { spawn "nautilus"; }
            Mod+T { spawn "Telegram"; }
            Mod+P { switch-preset-column-width; }
            Mod+S { focus-workspace "notes"; }
            Mod+Shift+S { move-column-to-workspace "notes"; }
            Mod+Ctrl+T { focus-workspace "term"; }
            Mod+G { toggle-column-tabbed-display; }
            Mod+Tab { focus-window-down; }
            Mod+Shift+Tab { focus-window-up; }
            Mod+Z { focus-workspace "notes"; }
            Mod+Period { spawn-sh "wl-paste >> $JOURNALS/$(date +%Y-%m-%d).md && notify-send \"pasted into $(date +%Y-%m-%d).md!\""; }
            Mod+V { spawn-sh "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"; }

            Mod+H { focus-column-left; }
            Mod+L { focus-column-right; }
            Mod+K { focus-window-up; }
            Mod+J { focus-window-down; }

            Mod+Shift+H { move-column-left; }
            Mod+Shift+L { move-column-right; }
            Mod+Shift+K { move-window-up; }
            Mod+Shift+J { move-window-down; }

            Mod+Ctrl+H { focus-workspace-up; }
            Mod+Ctrl+K { focus-workspace-up; }
            Mod+Ctrl+L { focus-workspace-down; }
            Mod+Ctrl+J { focus-workspace-down; }
            Mod+Ctrl+Shift+H { move-column-to-workspace-up; }
            Mod+Ctrl+Shift+K { move-column-to-workspace-up; }
            Mod+Ctrl+Shift+L { move-column-to-workspace-down; }
            Mod+Ctrl+Shift+J { move-column-to-workspace-down; }

            Mod+Alt+H { consume-or-expel-window-left; }
            Mod+Alt+L { consume-or-expel-window-right; }
            Mod+Alt+K { move-window-up; }
            Mod+Alt+J { move-window-down; }

            Mod+1 { focus-workspace 1; }
            Mod+2 { focus-workspace 2; }
            Mod+3 { focus-workspace 3; }
            Mod+4 { focus-workspace 4; }
            Mod+5 { focus-workspace 5; }
            Mod+6 { focus-workspace 6; }
            Mod+7 { focus-workspace 7; }
            Mod+8 { focus-workspace 8; }
            Mod+9 { focus-workspace 9; }
            Mod+0 { focus-workspace 10; }

            Mod+Shift+1 { move-column-to-workspace 1; }
            Mod+Shift+2 { move-column-to-workspace 2; }
            Mod+Shift+3 { move-column-to-workspace 3; }
            Mod+Shift+4 { move-column-to-workspace 4; }
            Mod+Shift+5 { move-column-to-workspace 5; }
            Mod+Shift+6 { move-column-to-workspace 6; }
            Mod+Shift+7 { move-column-to-workspace 7; }
            Mod+Shift+8 { move-column-to-workspace 8; }
            Mod+Shift+9 { move-column-to-workspace 9; }
            Mod+Shift+0 { move-column-to-workspace 10; }

            XF86AudioLowerVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%-"; }
            XF86AudioRaiseVolume allow-when-locked=true { spawn "wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "5%+"; }
            XF86AudioMute allow-when-locked=true { spawn "wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"; }
            XF86AudioPrev allow-when-locked=true { spawn "playerctl" "previous"; }
            XF86AudioNext allow-when-locked=true { spawn "playerctl" "next"; }
            XF86AudioPlay allow-when-locked=true { spawn "playerctl" "play-pause"; }
            XF86Calculator { spawn "gnome-calculator"; }
            Mod+KP_Enter { spawn "gnome-calculator"; }

            XF86MonBrightnessDown allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "10-"; }
            XF86MonBrightnessUp allow-when-locked=true { spawn "${pkgs.brightnessctl}/bin/brightnessctl" "set" "+10"; }

            Mod+Ctrl+W { spawn "wallpaper-manager" "download"; }

            Mod+BracketRight { focus-monitor-right; }
            Mod+BracketLeft { focus-monitor-left; }

            Pause { spawn "swaylock" "-f"; }
            Ctrl+Shift+Pause { spawn-sh "swaylock -f & systemctl suspend"; }
            Mod+Alt+Ctrl+Equal { spawn "dunstctl" "set-paused" "toggle"; }
            Mod+Alt+Ctrl+BracketRight { spawn "systemctl" "reboot"; }

            Print { screenshot; }
            Shift+Print { screenshot-screen; }
            Alt+Print { screenshot-window; }

            Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
        }
      '';
    };
  };
}

{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.default.desktop.wayland.hyprland;
  theme = config.default.theme;
  p = theme.palette;

  lua = lib.generators.mkLuaInline;
  luaQuote = builtins.toJSON;
  luaKey =
    parts:
    lua (
      lib.concatStringsSep ''.. " + " .. '' (
        map (part: if part == "mainMod" then "mainMod" else luaQuote part) parts
      )
    );
  mkBind = keys: dispatcher: {
    _args = [
      (luaKey keys)
      (lua dispatcher)
    ];
  };
  mkBindWith = keys: dispatcher: options: {
    _args = [
      (luaKey keys)
      (lua dispatcher)
      options
    ];
  };
  exec = command: "hl.dsp.exec_cmd(${luaQuote command})";
  focusWorkspace = workspace: "hl.dsp.focus({ workspace = ${luaQuote workspace} })";
  moveToWorkspace =
    workspace: "hl.dsp.window.move({ workspace = ${luaQuote workspace}, follow = false })";
  focusDirection = direction: "hl.dsp.focus({ direction = ${luaQuote direction} })";
  moveDirection = direction: "hl.dsp.window.move({ direction = ${luaQuote direction} })";
  moveIntoGroup = direction: "hl.dsp.window.move({ into_group = ${luaQuote direction} })";
  focusMonitor = monitor: "hl.dsp.focus({ monitor = ${luaQuote monitor} })";
  hyprctl = "${pkgs.hyprland}/bin/hyprctl";
  hyprlock = "${pkgs.hyprlock}/bin/hyprlock";
  loginctl = "${pkgs.systemd}/bin/loginctl";
  pidof = "${pkgs.procps}/bin/pidof";
  sleep = "${pkgs.coreutils}/bin/sleep";
  systemctl = "${pkgs.systemd}/bin/systemctl";
  hyprDispatch = dispatcher: "${hyprctl} dispatch ${lib.escapeShellArg dispatcher}";
  dpms = action: hyprDispatch ''hl.dsp.dpms({ action = "${action}" })'';
  dpmsOn = dpms "enable";
  dpmsOff = dpms "disable";
  expandHome =
    path:
    if lib.hasPrefix "~/" path then config.home.homeDirectory + lib.removePrefix "~" path else path;
  wallpaperPath = monitor: expandHome monitor.wallpaper;
  bezierPoints =
    coords:
    let
      values = map (s: builtins.fromJSON (lib.strings.trim s)) (lib.splitString "," coords);
    in
    [
      [
        (builtins.elemAt values 0)
        (builtins.elemAt values 1)
      ]
      [
        (builtins.elemAt values 2)
        (builtins.elemAt values 3)
      ]
    ];

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = with pkgs; [
      grim
      slurp
      wl-clipboard
      libnotify
      jq
      hyprland
      coreutils
    ];
    text = ''
      mode="''${1:-area}"
      dir="$HOME/Pictures/Screenshots"
      mkdir -p "$dir"
      file="$dir/$(date +%Y%m%d_%H%M%S).png"

      case "$mode" in
        area)
          if ! geom=$(slurp -d); then
            notify-send -a Screenshot "Screenshot cancelled"
            exit 0
          fi
          grim -g "$geom" "$file"
          ;;
        screen)
          grim "$file"
          ;;
        active)
          geom=$(hyprctl activewindow -j \
            | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
          grim -g "$geom" "$file"
          ;;
        *)
          echo "usage: screenshot {area|screen|active}" >&2
          exit 1
          ;;
      esac

      wl-copy --type image/png < "$file"
      notify-send -a Screenshot -i "$file" "Screenshot saved" "$file"
    '';
  };
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
      screenshot

      fastfetch
      libnotify
      playerctl
      pavucontrol
      #hyprland-qtutils
    ];

    xdg.configFile."hypr/hyprland.conf" = {
      force = true;
      text = ''
        # Managed by Home Manager.
        # Hyprland 0.55+ config is generated at ~/.config/hypr/hyprland.lua.
      '';
    };

    programs.wofi.enable = true;
    services.playerctld.enable = true;
    services.cliphist.enable = true;
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          after_sleep_cmd = dpmsOn;
          before_sleep_cmd = "hypr-kbd-layout-reset ; ${loginctl} lock-session";
          ignore_dbus_inhibit = false;
          lock_cmd = "${pidof} hyprlock || ${hyprlock}";
          on_lock_cmd = "${pkgs.runtimeShell} -c ${lib.escapeShellArg "${sleep} 60; ${pidof} hyprlock >/dev/null && ${dpmsOff}"}";
          on_unlock_cmd = dpmsOn;
        };

        listener = [
          {
            timeout = 300;
            on-timeout = "${hyprlock} --grace 15";
          }
          {
            timeout = 360;
            on-timeout = dpmsOff;
            on-resume = dpmsOn;
          }
        ];
      };
    };
    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
          no_fade_in = false;
          ignore_empty_input = true;
        };

        background = [
          {
            path = "screenshot";
            blur_passes = 3;
            blur_size = 8;
          }
        ];

        label = {
          text = "$LAYOUT";
          color = "rgba(200, 200, 200, 1.0)";
          font_size = 14;
          font_family = "Noto Sans";
          position = "0, 10";
          halign = "center";
          valign = "bottom";
        };

        input-field = [
          {
            size = "200, 50";
            position = "0, -80";
            monitor = "";
            dots_center = true;
            fade_on_empty = false;
            font_color = "rgb(202, 211, 245)";
            inner_color = "rgb(91, 96, 120)";
            outer_color = "rgb(24, 25, 38)";
            outline_thickness = 5;
            placeholder_text = "Password...";
            shadow_passes = 2;
          }
        ];
      };
    };

    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload = map wallpaperPath config.monitors;

        wallpaper = map (m: "${m.name},${wallpaperPath m}") config.monitors;
      };
    };

    qt = {
      enable = true;
      platformTheme.name = "gtk3";
      style.name = "adwaita-gtk";
    };

    wayland.windowManager.hyprland = {
      enable = true;
      configType = "lua";
      xwayland.enable = true;
      # set the Hyprland and XDPH packages to null to use the ones from the NixOS module
      package = null;
      portalPackage = null;
      settings =
        let
          startupCommands = [
            "hyprpaper"
            "hyprctl setcursor Bibata-Modern-Ice 22"
            "kitty"
          ]
          ++ cfg.autostart;
          env = name: value: {
            _args = [
              name
              value
            ];
          };
        in
        {
          mainMod = {
            _var = "SUPER";
          };

          on = {
            _args = [
              "hyprland.start"
              (lua ''
                function()
                ${lib.concatMapStrings (command: "  hl.exec_cmd(${luaQuote command})\n") startupCommands}end
              '')
            ];
          };

          env = [
            (env "XCURSOR_SIZE" "24")
            (env "XDG_CURRENT_DESKTOP" "Hyprland")
            (env "XDG_SESSION_TYPE" "wayland")
            (env "XDG_SESSION_DESKTOP" "Hyprland")
            (env "QT_QPA_PLATFORM" "wayland;xcb")
            (env "QT_QPA_PLATFORMTHEME" "qt6ct")
            (env "QT_WAYLAND_DISABLE_WINDOWDECORATION" "1")
            (env "QT_AUTO_SCREEN_SCALE_FACTOR" "1")
            (env "MOZ_ENABLE_WAYLAND" "1")
            (env "GDK_SCALE" "1")
            (env "GDK_BACKEND" "wayland,x11")
            (env "DEFAULT_FILE_MANAGER" "thunar")
            (env "XDG_FILE_MANAGER" "thunar")
          ];

          config = {
            general = {
              gaps_in = 4;
              gaps_out = 8;
              border_size = 2;
              "col.active_border" = {
                colors = [
                  "rgb(${p.accent})"
                  "rgb(${p.accent2})"
                ];
                angle = 45;
              };
              "col.inactive_border" = "rgba(${p.surfaceAlt}aa)";
              layout = "dwindle";
              resize_on_border = true;
            };

            dwindle = {
              preserve_split = true;
            };

            master = {
              orientation = "master";
            };

            decoration = {
              rounding = theme.rounding;
              blur = {
                enabled = true;
                size = 6;
                passes = 2;
                new_optimizations = true;
                ignore_opacity = false;
                xray = true;
              };
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
              numlock_by_default = true;
              sensitivity = 0.15;
              follow_mouse = 1;
              touchpad = {
                natural_scroll = true;
                drag_lock = true;
              };
            };

            animations = {
              enabled = true;
            };
          };

          device = [
            {
              name = "getech-huge-trackball-1";
              scroll_method = "on_button_down";
              scroll_button = 279;
              natural_scroll = true;
            }
            {
              name = "ploopy-corporation-ploopy-adept-trackball-mouse";
              natural_scroll = true;
            }
          ];

          monitor = map (
            m:
            if m.enabled then
              {
                output = m.name;
                mode = "${toString m.width}x${toString m.height}@${toString m.refreshRate}";
                position = "${toString m.x}x${toString m.y}";
                scale = m.scale;
                transform = builtins.fromJSON m.transform;
              }
            else
              {
                output = m.name;
                disabled = true;
              }
          ) config.monitors;

          workspace_rule = lib.lists.flatten (
            map (
              m:
              map (w: {
                workspace = w;
                monitor = m.name;
              }) m.workspaces
            ) config.monitors
          );

          curve = [
            {
              _args = [
                "overshot"
                {
                  type = "bezier";
                  points = bezierPoints theme.animationsBezier;
                }
              ];
            }
            {
              _args = [
                "smooth"
                {
                  type = "bezier";
                  points = [
                    [
                      0.13
                      0.99
                    ]
                    [
                      0.29
                      1
                    ]
                  ];
                }
              ];
            }
            {
              _args = [
                "wind"
                {
                  type = "bezier";
                  points = [
                    [
                      0.05
                      0.9
                    ]
                    [
                      0.1
                      1.05
                    ]
                  ];
                }
              ];
            }
          ];

          animation = [
            {
              leaf = "windows";
              enabled = true;
              speed = 6;
              bezier = "wind";
              style = "slide";
            }
            {
              leaf = "windowsIn";
              enabled = true;
              speed = 6;
              bezier = "wind";
              style = "slide";
            }
            {
              leaf = "windowsOut";
              enabled = true;
              speed = 5;
              bezier = "smooth";
              style = "popin 80%";
            }
            {
              leaf = "border";
              enabled = true;
              speed = 10;
              bezier = "default";
            }
            {
              leaf = "borderangle";
              enabled = true;
              speed = 30;
              bezier = "smooth";
              style = "loop";
            }
            {
              leaf = "fade";
              enabled = true;
              speed = 8;
              bezier = "smooth";
            }
            {
              leaf = "workspaces";
              enabled = true;
              speed = 6;
              bezier = "overshot";
              style = "slidevert";
            }
          ];

          window_rule = [
            {
              match.title = "^(kitty-default)";
              workspace = "special:notes";
            }
            {
              match.title = "^(kitty-scratch)";
              workspace = "special:term";
            }
            {
              match.class = "^(kitty)$";
              opacity = "0.9 0.9";
            }

            {
              match.title = "Calculator";
              float = true;
            }
            {
              match.title = "kitty-float";
              float = true;
            }
            {
              match.class = "^(org.kde.dolphin)$";
              match.title = "^(Progress Dialog — Dolphin)$";
              float = true;
            }
            {
              match.class = "^(org.kde.dolphin)$";
              match.title = "^(Copying — Dolphin)$";
              float = true;
            }
            {
              match.title = "(Firefox — Sharing Indicator)";
              float = true;
            }
            {
              match.class = "^(firefox)$";
              match.title = "^(Picture-in-Picture)$";
              float = true;
            }
            {
              match.class = "^(firefox)$";
              match.title = "^(Library)$";
              float = true;
            }
            {
              match.class = "^(vlc)$";
              float = true;
            }
            {
              match.class = "^(org.pulseaudio.pavucontrol)$";
              float = true;
            }
            {
              match.class = "^(blueman-manager)$";
              float = true;
            }
            {
              match.class = "^(nm-applet)$";
              float = true;
            }
            {
              match.class = "^(nm-connection-editor)$";
              float = true;
            }
            {
              match.class = "^(org.kde.polkit-kde-authentication-agent-1)$";
              float = true;
            }
            {
              match.class = "org.telegram.desktop";
              float = true;
            }
            {
              match.class = "org.telegram.desktop";
              size = [
                500
                900
              ];
            }
          ];

          bind = [
            (mkBind [ "mainMod" "Return" ] (exec "kitty"))
            (mkBind [ "mainMod" "q" ] "hl.dsp.window.close()")
            (mkBind [ "mainMod" "SHIFT" "q" ] "hl.dsp.exit()")
            (mkBind [ "mainMod" "SHIFT" "b" ] (
              exec "${pkgs.procps}/bin/pkill -SIGUSR1 -x .waybar-wrapped || ${pkgs.procps}/bin/pkill -SIGUSR1 -x ironbar"
            ))
            (mkBind [ "mainMod" "f" ] ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')
            (mkBind [ "mainMod" "m" ] ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
            (mkBind [ "mainMod" "SHIFT" "t" ] ''hl.dsp.window.float({ action = "toggle" })'')
            (mkBind [ "mainMod" "d" ] (exec "fuzzel"))
            (mkBind [ "ALT" "e" ] (exec "wofi-emoji"))

            (mkBind [ "mainMod" "r" ] (
              exec "kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=1c --hold"
            ))
            (mkBind [ "mainMod" "CTRL" "r" ] (
              exec "kitty --title='kitty-float' --override initial_window_width=100c --override initial_window_height=40c --hold"
            ))
            (mkBind [ "mainMod" "o" ] (
              exec "kitty --title='kitty-float' --override initial_window_width=150c --override initial_window_height=42c zsh -ic 'zk edit --interactive'"
            ))
            (mkBind [ "mainMod" "e" ] (
              exec "kitty --title='kitty-float' --override initial_window_width=80c --override initial_window_height=20c qke"
            ))

            (mkBind [ "mainMod" "n" ] (exec "nautilus"))
            (mkBind [ "mainMod" "t" ] (exec "Telegram"))
            (mkBind [ "mainMod" "P" ] "hl.dsp.window.pseudo()")
            (mkBind [ "mainMod" "s" ] ''hl.dsp.workspace.toggle_special("notes")'')
            (mkBind [ "mainMod" "SHIFT" "S" ] (moveToWorkspace "special:notes"))
            (mkBind [ "mainMod" "CTRL" "t" ] ''hl.dsp.workspace.toggle_special("term")'')
            (mkBind [ "mainMod" "g" ] "hl.dsp.group.toggle()")
            (mkBind [ "mainMod" "TAB" ] "hl.dsp.group.next()")
            (mkBind [ "mainMod" "SHIFT" "TAB" ] "hl.dsp.group.prev()")
            (mkBind [ "mainMod" "z" ] ''hl.dsp.focus({ window = "title:kitty-journal" })'')
            (mkBind [ "mainMod" "period" ] (
              exec ''zsh -c 'wl-paste >> $JOURNALS/$(date +%Y-%m-%d).md && notify-send "pasted into $(date +%Y-%m-%d).md!"''
            ))
            (mkBind [ "mainMod" "v" ] (exec "cliphist list | fuzzel --dmenu | cliphist decode | wl-copy"))

            (mkBind [ "mainMod" "h" ] (focusDirection "l"))
            (mkBind [ "mainMod" "l" ] (focusDirection "r"))
            (mkBind [ "mainMod" "k" ] (focusDirection "u"))
            (mkBind [ "mainMod" "j" ] (focusDirection "d"))

            (mkBind [ "mainMod" "SHIFT" "h" ] (moveDirection "l"))
            (mkBind [ "mainMod" "SHIFT" "l" ] (moveDirection "r"))
            (mkBind [ "mainMod" "SHIFT" "k" ] (moveDirection "u"))
            (mkBind [ "mainMod" "SHIFT" "j" ] (moveDirection "d"))

            (mkBind [ "mainMod" "CTRL" "h" ] (focusWorkspace "r-1"))
            (mkBind [ "mainMod" "CTRL" "k" ] (focusWorkspace "r-1"))
            (mkBind [ "mainMod" "CTRL" "l" ] (focusWorkspace "r+1"))
            (mkBind [ "mainMod" "CTRL" "j" ] (focusWorkspace "r+1"))
            (mkBind [ "mainMod" "CTRL" "SHIFT" "h" ] (moveToWorkspace "r-1"))
            (mkBind [ "mainMod" "CTRL" "SHIFT" "k" ] (moveToWorkspace "r-1"))
            (mkBind [ "mainMod" "CTRL" "SHIFT" "l" ] (moveToWorkspace "r+1"))
            (mkBind [ "mainMod" "CTRL" "SHIFT" "j" ] (moveToWorkspace "r+1"))

            (mkBind [ "mainMod" "ALT" "h" ] (moveIntoGroup "l"))
            (mkBind [ "mainMod" "ALT" "l" ] (moveIntoGroup "r"))
            (mkBind [ "mainMod" "ALT" "k" ] (moveIntoGroup "u"))
            (mkBind [ "mainMod" "ALT" "j" ] (moveIntoGroup "d"))
          ]
          ++ lib.lists.flatten (
            map (
              n:
              let
                key = if n == 10 then "0" else toString n;
                workspace = toString n;
              in
              [
                (mkBind [ "mainMod" key ] (focusWorkspace workspace))
                (mkBind [ "mainMod" "SHIFT" key ] (moveToWorkspace workspace))
              ]
            ) (lib.range 1 10)
          )
          ++ [
            (mkBind [ "XF86AudioLowerVolume" ] (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))
            (mkBind [ "XF86AudioRaiseVolume" ] (exec "wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"))
            (mkBind [ "XF86AudioMute" ] (exec "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))
            (mkBind [ "XF86AudioPrev" ] (exec "playerctl previous"))
            (mkBind [ "XF86AudioNext" ] (exec "playerctl next"))
            (mkBind [ "XF86AudioPlay" ] (exec "playerctl play-pause"))
            (mkBind [ "XF86Calculator" ] (exec "gnome-calculator"))
            (mkBind [ "mainMod" "KP_ENTER" ] (exec "gnome-calculator"))

            (mkBind [ "XF86MonBrightnessDown" ] (exec "${pkgs.brightnessctl}/bin/brightnessctl set 10-"))
            (mkBind [ "XF86MonBrightnessUp" ] (exec "${pkgs.brightnessctl}/bin/brightnessctl set +10"))

            (mkBind [ "mainMod" "CTRL" "w" ] (exec "wallpaper-manager download"))

            (mkBind [ "mainMod" "bracketright" ] (focusMonitor "r"))
            (mkBind [ "mainMod" "bracketleft" ] (focusMonitor "l"))

            (mkBind [ "Pause" ] (exec "${hyprlock} --grace 5"))
            (mkBind [ "CTRL" "SHIFT" "Pause" ] (exec "${loginctl} lock-session & ${systemctl} suspend"))
            (mkBind [ "mainMod" "ALT" "CTRL" "equal" ] (exec "dunstctl set-paused toggle"))
            (mkBind [ "mainMod" "ALT" "CTRL" "bracketright" ] (exec "systemctl reboot"))

            (mkBind [ "Print" ] (exec "screenshot area"))
            (mkBind [ "SHIFT" "Print" ] (exec "screenshot screen"))
            (mkBind [ "ALT" "Print" ] (exec "screenshot active"))

            (mkBindWith [ "mainMod" "mouse:272" ] "hl.dsp.window.drag()" { mouse = true; })
            (mkBindWith [ "mainMod" "mouse:273" ] "hl.dsp.window.resize()" { mouse = true; })
          ];
        };
    };
  };
}

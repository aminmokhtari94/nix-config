{pkgs, ...}: {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "amin";
    homeDirectory = "/home/amin";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.11";
  };
  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  xdg.configFile."hypr/hyprland.lua".force = true;

  default = {
    theme.name = "embarl";
    gpg.enable = false;
    # kube.enable = true;
    # vpn.enable = true;
    # lang = {
    #   go.enable = true;
    #   nodejs.enable = true;
    #   python.enable = true;
    #   cpp.enable = true;
    #   esp-idf.enable = true;
    # };
    desktop = {
      enable = true;
      apps = with pkgs; [
      ];
      wayland = {
        hyprland = {
          enable = true;
          autostart = ["Throne"];
          layout = "scrolling";
        };
        niri = {
          enable = true;
          autostart = ["Throne"];
        };
      };
      browser.enable = true;
      kitty.enable = true;
      gtk.enable = false;
      wayland.waybar.enable = true;
      wayland.ironbar = {
        enable = false;
        desktop = true; # drop battery/network modules
      };
      wayland.launcher = {
        enable = true;
        backend = "fuzzel";
      };
      wayland.shaders = {
        enable = true;
        style = "vignette"; # try "crt" or "warm"
      };
      dunst.enable = true;
      nm-applet.enable = true;
      editor = {
        vscode.enable = false;
        cursor.enable = false;
      };
      wine.enable = false;
    };
    agent = {
      claude.enable = false;
      codex.enable = false;
    };
  };

  keyboard = {
    options = "grp:alt_shift_toggle";
  };

  monitors = [
    {
      name = "eDP-1";
      width = 1920;
      height = 1080;
      scale = "1";
      refreshRate = 60;
      workspaces = [
        "1"
        "2"
        "3"
        "4"
        "5"
        "6"
      ];
      wallpaper = "~/Pictures/wallpaper.jpg";
    }
  ];
}

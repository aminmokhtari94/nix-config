{ pkgs, ... }: {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "amin";
    homeDirectory = "/home/amin";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.11";
  };
  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  default = {
    theme.name = "embarl";
    gpg.enable = false;
    kube.enable = true;
    vpn.enable = true;
    lang = {
      go.enable = true;
      python.enable = true;
    };
    desktop = {
      enable = true;
      apps = with pkgs; [ mongodb-compass mqtt-explorer redisinsight postman ];
      wayland = {
        hyprland = {
          enable = true;
          autostart = [ "nekoray" ];
        };
      };
      browser.enable = true;
      kitty.enable = true;
      gtk.enable = true;
      wayland.waybar.enable = true;
      dunst.enable = true;
      nm-applet.enable = true;
      editor = {
        vscode.enable = true;
        cursor.enable = false;
      };
    };
  };

  keyboard = { options = "grp:alt_shift_toggle"; };

  monitors = [
    {
      name = "DP-3";
      width = 1920;
      height = 1080;
      scale = "1";
      transform = "1";
      refreshRate = 60;
      workspaces = [ "7" "8" "9" ];
      wallpaper = "~/Pictures/wallpaper-DP-3.jpg";
    }
    {
      name = "DP-1";
      width = 1920;
      height = 1080;
      x = 1080;
      scale = "1";
      refreshRate = 60;
      workspaces = [ "1" "2" "3" ];
      wallpaper = "~/Pictures/wallpaper-DP-1.jpg";
    }
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      x = 3000;
      scale = "1";
      refreshRate = 60;
      workspaces = [ "4" "5" "6" ];
      wallpaper = "~/Pictures/wallpaper-DP-2.jpg";
    }
  ];

}

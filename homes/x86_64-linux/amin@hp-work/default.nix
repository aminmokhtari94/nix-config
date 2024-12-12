{config, pkgs, ... }:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "amin";
    homeDirectory = "/home/amin";
#    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.11";
  };
  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  default = {
    theme.name = "inspired";
    gpg.enable = false;
    vscode.enable = true;
    kube.enable = true;
    v2ray.enable = true;
    desktop = {
      enable = true;
      wayland.hyprland = {
        enable = true;
        autostart = [ ];
      };
      gtk.enable = true;
      wayland.waybar.enable = true;
      dunst.enable = true;
      nm-applet.enable = true;
    };
  };

  keyboard = {
    options = "grp:alt_shift_toggle";
  };

  monitors = [
    {
      name = "DP-3";
      width = 1920;
      height = 1080;
      scale = "1";
      transform = "1";
      refreshRate = 60;
      workspaces = [ "7" "8" "9" ];
      wallpaper = "~/Pictures/wallpaper.jpg";
    }
    {
      name = "DP-1";
      width = 1920;
      height = 1080;
      x = 1080;
      scale = "1";
      refreshRate = 60;
      workspaces = [ "1" "2" "3" ];
      wallpaper = "~/Pictures/wallpaper.jpg";
    }
    {
      name = "DP-2";
      width = 1920;
      height = 1080;
      x = 3000;
      scale = "1";
      refreshRate = 60;
      workspaces = [ "4" "5" "6" ];
      wallpaper = "~/Pictures/wallpaper.jpg";
    }
  ];

}

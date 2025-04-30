{ config, pkgs, ... }: {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "amin";
    homeDirectory = "/home/amin";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "24.05";
  };
  # Nicely reload system units when changing configs
  #systemd.user.startServices = "sd-switch";

  default = {
    theme.name = "embarl";
    gpg.enable = false;
    vscode.enable = true;
    kube.enable = true;
    v2ray.enable = true;
    vpn.enable = true;
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

  keyboard = { options = "grp:alt_shift_toggle"; };

  monitors = [{
    name = "eDP-1";
    width = 1920;
    height = 1080;
    scale = "1";
    refreshRate = 60;
    workspaces = [ "1" "2" "3" "4" "5" "6" ];
    wallpaper = "~/Pictures/wallpaper.jpg";
  }];

}

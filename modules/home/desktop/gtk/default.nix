{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.default.desktop.gtk;
in
{
  options.default.desktop.gtk.enable = lib.mkEnableOption "GTK configuration";

  config = lib.mkIf cfg.enable {
    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.colloid-gtk-theme;
        name = "Colloid-Dark";
      };

      gtk4.theme = config.gtk.theme;

      iconTheme = {
        package = pkgs.colloid-icon-theme;
        name = "Colloid-Dark";
      };

      cursorTheme = {
        package = pkgs.bibata-cursors;
        name = "Bibata-Modern-Ice";
      };
    };
  };
}

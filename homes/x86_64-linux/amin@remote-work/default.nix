{ config, pkgs, ... }: {
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "amin";
    homeDirectory = "/home/amin";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.05";
  };

  default = {
    theme.name = "embarl";
    gpg.enable = false;
    vscode.enable = false;
    cursor.enable = false;
    kube.enable = true;
    # v2ray.enable = true;
    vpn.enable = false;
    lang = {
      go.enable = true;
      python.enable = true;
    };
    desktop = { enable = false; };
  };
}

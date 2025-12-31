{ ... }:
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "amin";
    homeDirectory = "/home/amin";
    # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
    stateVersion = "25.05";
  };

  default = {
    theme.name = "inspored";
    gpg.enable = false;
    kube.enable = true;
    lang = {
      go.enable = true;
      python.enable = false;
    };
    desktop = {
      enable = false;
    };
  };
}

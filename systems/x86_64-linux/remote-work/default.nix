{ modulesPath, lib, pkgs, config, ... }@args: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Tehran";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = map lib.lowPrio [ pkgs.curl pkgs.gitMinimal ];

  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  virtualisation.docker.enable = true;

  users.users.amin = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.amin-passwd.path;
    extraGroups =
      [ "wheel" "docker" "networkmanager" ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGlj5STbxgr0chPN3kzTPjSZYLBixUoEoBRWCwHqA8z amin@n550jv"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5LdF5nCTvyc7vVkcBo+KLdPChPjccy4735AfKKfSaC work301"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGlj5STbxgr0chPN3kzTPjSZYLBixUoEoBRWCwHqA8z amin@n550jv"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5LdF5nCTvyc7vVkcBo+KLdPChPjccy4735AfKKfSaC work301"
  ];

  nix.settings.trusted-users = [ "amin" ];
  nix.extraOptions = ''
    extra-substituters = https://nix-community.cachix.org
    extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=

    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';

  system.stateVersion = "25.05";
}

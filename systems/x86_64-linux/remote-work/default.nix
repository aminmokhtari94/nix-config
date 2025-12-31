{
  modulesPath,
  lib,
  pkgs,
  config,
  ...
}@args:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disk-config.nix
  ];
  boot.loader.grub = {
    devices = [ "nodev" ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  # Set your time zone.
  time.timeZone = "Asia/Tehran";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  environment.systemPackages = map lib.lowPrio [
    pkgs.curl
    pkgs.gitMinimal
  ];

  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  # networking.proxy.default = "http://172.16.100.59:2081";
  # networking.proxy.noProxy =
  #   "127.0.0.1,::1,localhost,192.168.1.0/24,192.168.111.0/24,172.16.100.0/24";
  # environment.variables = {
  #   https_proxy = "http://172.16.100.59:2081";
  #   no_proxy =
  #     "127.0.0.1,::1,localhost,192.168.1.0/24,192.168.111.0/24,172.16.100.0/24";
  # };

  services.dnsmasq = {
    enable = true;

    settings = {
      address = [
        "/cluster.local/127.0.0.1"
        "/kiz.local/172.18.0.9"
        "/panel.kiz.ir/172.18.0.9"
      ];
      no-resolv = true;
      server = [
        "1.1.1.1"
        "8.8.8.8"
      ];
    };
  };

  networking.networkmanager.enable = true;
  networking.resolvconf.enable = true;
  networking.firewall.enable = false;
  networking.firewall.allowedTCPPorts = [
    22
    2080
    2081
    3000
    8081
    5027
  ];

  networking.extraHosts = ''
    172.16.100.205 k8s.c02.kiz.ir
  '';

  users.users.amin = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.amin-passwd.path;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGlj5STbxgr0chPN3kzTPjSZYLBixUoEoBRWCwHqA8z amin@n550jv"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5LdF5nCTvyc7vVkcBo+KLdPChPjccy4735AfKKfSaC work301"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKsmJzyqZ3jvdz0C8AyMzkBwAXxcLAk12+P0+5Su1n/h phone_termius"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINby0+z+P0CzDer9jtyW6ppjTXwYV4g7pIum4MPsWkkZ phone_termux"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG1ldhcO45HmHAgGyi7KQkTetKdBCqlrtifK37Ez726A amin@worklaptop"
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGlj5STbxgr0chPN3kzTPjSZYLBixUoEoBRWCwHqA8z amin@n550jv"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5LdF5nCTvyc7vVkcBo+KLdPChPjccy4735AfKKfSaC work301"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINby0+z+P0CzDer9jtyW6ppjTXwYV4g7pIum4MPsWkkZ phone_termux"
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

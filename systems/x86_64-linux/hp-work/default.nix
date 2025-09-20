# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };

  programs.nix-ld.enable = true;

  networking.networkmanager.enable = true;
  services.dnsmasq = {
    enable = true;

    settings = {
      address = [
        "/cluster.local/127.0.0.1"
        "/kiz.local/172.18.0.9"
        "/panel.kiz.ir/172.18.0.9"
      ];
      no-resolv = true;
      server = [ "1.1.1.1" "8.8.8.8" ];
    };
  };

  networking.extraHosts = ''
    172.16.100.205 k8s.c02.kiz.ir
    172.16.100.40 grafana.prometheus.cluster.local
    172.16.100.41 acl.kiz.ir grpc.abrso.ir grpc.kiz.ir terabar.acl.kiz.ir lone.acl.kiz.ir abrso.acl.kiz.ir grpc.terabar.ir all.kiz.ir

    172.16.100.201 redpanda-0
    172.16.100.209 redpanda-1
    172.16.100.202 redpanda-2
  '';
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Asia/Tehran";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    #videoDrivers = [ "nvidia" ];
    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };
  };
  #services.desktopManager.plasma6.enable= true;
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };
  services.dbus.enable = true;
  programs.dconf.enable = true;

  # needs to be install on NixOS Module
  # Without this, you may have issues with XDG Portals, or missing session files in your Display Manager.
  programs.hyprland.enable = true;
  xdg.portal = { extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; };

  environment.shells = [ pkgs.zsh ];
  programs.zsh.enable = true;

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable automatic garbage collection for store paths older than 7 days.
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 7d";
  };

  # Enable automatic store optimization.
  # nix.optimise.automatic = true;

  users.users.amin = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.amin-passwd.path;
    extraGroups = [
      "wheel"
      "docker"
      "dialout"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGlj5STbxgr0chPN3kzTPjSZYLBixUoEoBRWCwHqA8z amin@n550jv"
    ];
  };

  # programs.firefox.enable = true;

  default.v2ray = { enable = true; };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [ wget ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  nix.settings.trusted-users = [ "amin" ];
  nix.extraOptions = ''
    extra-substituters = https://nix-community.cachix.org
    extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=

    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=

    extra-substituters = https://hyprland.cachix.org
    extra-trusted-public-keys = hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=

  '';

  # List services that you want to enable:
  programs.ssh = {
    extraConfig = ''
      Host remote-work
        HostName 172.16.100.229
        User amin
        SendEnv TERM
        SetEnv TERM=xterm-256color
    '';
  };
  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    # I'll disable this once I can connect.
  };

  services.udev.extraRules = ''
    # Logic Analyzer
    SUBSYSTEM=="usb", ATTR{idVendor}=="0925", ATTR{idProduct}=="3881", MODE="0666"
  '';

  # networking.proxy.default = "http://localhost:2080";
  # networking.proxy.noProxy =
  #   "127.0.0.1,::1,localhost,192.168.1.0/24,192.168.111.0/24,172.16.100.0/24";

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 2080 2081 3000 8081 ];
  #networking.enableIPv4Forwarding = true;
  networking.nat = {
    enable = true;
    externalInterface = "wg-rs";
    internalInterfaces = [ "eno1" ];
  };
  # networking.nftables.enable = true;
  # networking.nftables.ruleset = ''
  #   table inet filter {
  #     chain forward {
  #       type filter hook forward priority 0;
  #       policy drop;  # Default deny forwarding
  #       iifname "eno1" oifname "wg-rs" accept;
  #       iifname "wg-rs" oifname "eno1" accept;
  #     }
  #   }
  #   table ip nat {
  #     chain postrouting {
  #       type nat hook postrouting priority 100;
  #       oifname "wg-rs" masquerade;
  #     }
  #   }
  # '';

  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

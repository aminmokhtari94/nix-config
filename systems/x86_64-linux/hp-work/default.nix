# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = { "net.ipv4.ip_forward" = true; };
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  networking.extraHosts = ''

    # 172.16.100.40 api.kiz.ir emqx.kiz.ir asset.kiz.ir reg.kiz.ir minio.kiz.ir ops.kiz.ir api-v2.kiz.ir akhq.abrso.ir
    # 172.16.100.40 abrso.ir app.abrso.ir cms.abrso.ir next.abrso.ir api-next.abrso.ir api.abrso.ir emqx.abrso.ir metabase.abrso.ir
    # 172.16.100.40 terabar.ir app.terabar.ir cms.terabar.ir influxdb.abrso.ir
    # 172.16.100.40 rahkarsanat.ir cms.rahkarsanat.ir taiga.rahkarsanat.ir git.kiz.ir redpanda.kiz.ir
    # 172.16.100.41 acl.kiz.ir grpc.abrso.ir grpc.kiz.ir terabar.acl.kiz.ir lone.acl.kiz.ir abrso.acl.kiz.ir grpc.terabar.ir all.kiz.ir
    # 172.16.100.45 mqtt.abrso.ir

    172.16.100.205 k8s.c02.kiz.ir
    # 185.177.158.57 k8s.c02.kiz.ir
    172.16.100.40  grafana.prometheus.cluster.local

    127.0.0.1 mongodb-0.mongodb-headless.kiz.svc.cluster.local
    127.0.0.1 mongodb-1.mongodb-headless.kiz.svc.cluster.local
    127.0.0.1 mongodb-2.mongodb-headless.kiz.svc.cluster.local
    127.0.0.1 mongo-psmdb-db-rs0.kiz-db.svc.cluster.local
    127.0.0.1 mongo-psmdb-db-rs0-0.mongo-psmdb-db-rs0.kiz-db.svc.cluster.local
    127.0.0.1 mongo-psmdb-db-rs0-1.mongo-psmdb-db-rs0.kiz-db.svc.cluster.local
    127.0.0.1 mongo-psmdb-db-rs0-2.mongo-psmdb-db-rs0.kiz-db.svc.cluster.local

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

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 30d";
  };

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

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    # I'll disable this once I can connect.
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 22 2080 2081 ];
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

# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, ... }: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-6bf56ee3-51d4-47af-a530-30462a94be73".device =
    "/dev/disk/by-uuid/6bf56ee3-51d4-47af-a530-30462a94be73";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];
  networking.extraHosts = ''

    # 172.16.100.40 api.kiz.ir emqx.kiz.ir asset.kiz.ir reg.kiz.ir minio.kiz.ir ops.kiz.ir api-v2.kiz.ir akhq.abrso.ir
    # 172.16.100.40 abrso.ir app.abrso.ir cms.abrso.ir next.abrso.ir api-next.abrso.ir api.abrso.ir emqx.abrso.ir metabase.abrso.ir
    # 172.16.100.40 terabar.ir app.terabar.ir cms.terabar.ir influxdb.abrso.ir
    # 172.16.100.40 rahkarsanat.ir cms.rahkarsanat.ir taiga.rahkarsanat.ir git.kiz.ir redpanda.kiz.ir
    # 172.16.100.41 acl.kiz.ir grpc.abrso.ir grpc.kiz.ir terabar.acl.kiz.ir lone.acl.kiz.ir abrso.acl.kiz.ir grpc.terabar.ir all.kiz.ir
    # 172.16.100.45 mqtt.abrso.ir

    # 172.16.100.205 k8s.c02.kiz.ir
    185.177.158.57 k8s.c02.kiz.ir kasm.cluster.local
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
    172.18.0.10 employee.default.kiz.local
  '';

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
  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  virtualisation.docker.enable = true;
  # virtualisation.docker.storageDriver = "btrfs";
  virtualisation.libvirtd.enable = true;

  # Enable sound with pipewire.
  # hardware.pulseaudio.enable = false;

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

  hardware = {
    bluetooth.enable = true;
    enableRedistributableFirmware = true;
  };
  services.blueman.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Enable automatic garbage collection for store paths older than 7 days.
  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 7d";
  };

  # Enable automatic store optimization.
  # nix.optimise.automatic = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.amin = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.amin-passwd.path;
    extraGroups = [
      "wheel"
      "docker"
      "networkmanager"
      "libvirtd"
    ]; # Enable ‘sudo’ for the user.
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGlj5STbxgr0chPN3kzTPjSZYLBixUoEoBRWCwHqA8z amin@n550jv"
    ];
  };

  default.v2ray = { enable = true; };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    usbutils
    lshw
    virt-manager
    qemu
    libvirt
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.light = {
    enable = true;
    brightnessKeys.step = 5;
    brightnessKeys.enable = true;
  };

  nix.settings.trusted-users = [ "amin" ];
  nix.extraOptions = ''
    extra-substituters = https://nix-community.cachix.org
    extra-trusted-public-keys = nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=

    extra-substituters = https://devenv.cachix.org
    extra-trusted-public-keys = devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=

    extra-substituters = https://hyprland.cachix.org
    extra-trusted-public-keys = hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=

  '';

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [ 2080 ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}

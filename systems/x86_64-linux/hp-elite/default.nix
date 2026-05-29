# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).
{
  config,
  pkgs,
  ...
}: let
  xmm7360Pci = config.boot.kernelPackages.callPackage (
    {
      fetchFromGitHub,
      kernel,
      lib,
      makeWrapper,
      python3,
      stdenv,
    }:
      stdenv.mkDerivation {
        pname = "xmm7360-pci";
        version = "unstable-2024-02-24";

        src = fetchFromGitHub {
          owner = "xmm7360";
          repo = "xmm7360-pci";
          rev = "a8ff2c6ceee84cbe74df8a78cfaa5a016d362ed4";
          hash = "sha256-wwm9ELALiJrC54azyJ95Rm3pcGLYzhxEe9mcCUvSVKk=";
        };

        nativeBuildInputs = kernel.moduleBuildDependencies ++ [makeWrapper];

        postPatch = ''
          substituteInPlace xmm7360.c \
            --replace-fail "static int xmm7360_tty_write(struct tty_struct *tty," \
                           "static ssize_t xmm7360_tty_write(struct tty_struct *tty," \
            --replace-fail "const unsigned char *buffer, int count)" \
                           "const unsigned char *buffer, size_t count)"
        '';

        makeFlags = [
          "KVERSION=${kernel.modDirVersion}"
          "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
        ];

        installPhase = ''
          runHook preInstall

          install -D -m 444 xmm7360.ko \
            "$out/lib/modules/${kernel.modDirVersion}/extra/xmm7360.ko"

          mkdir -p "$out/libexec/xmm7360-pci"
          cp -r rpc examples scripts xmm7360.ini.sample "$out/libexec/xmm7360-pci/"

          makeWrapper ${
            python3.withPackages (ps: [
              ps.configargparse
              ps.dbus-python
              ps.pyroute2
            ])
          }/bin/python3 "$out/bin/xmm7360-up" \
            --add-flags "$out/libexec/xmm7360-pci/rpc/open_xdatachannel.py"

          runHook postInstall
        '';

        meta = {
          description = "Experimental PCI driver and userspace tools for Intel XMM7360/Fibocom L850-GL WWAN modems";
          homepage = "https://github.com/xmm7360/xmm7360-pci";
          license = lib.licenses.gpl2Only;
          platforms = lib.platforms.linux;
        };
      }
  ) {};
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-fortisslvpn
      networkmanager-iodine
      networkmanager-l2tp
      networkmanager-openconnect
      networkmanager-openvpn
      networkmanager-sstp
      networkmanager-strongswan
      networkmanager-vpnc
    ];
  };
  # This modem is driven through xmm7360-pci RPC. ModemManager probes the
  # ttyXMM ports as a generic AT modem and can leave it in a failed state.
  networking.modemmanager.enable = false;
  hardware.usb-modeswitch.enable = true;

  # Experimental Intel XMM7360/Fibocom L850-GL support. The stock iosm driver
  # exposes this card, but ModemManager cannot use it in RPC mode.
  boot.kernelParams = ["iommu=off"];
  boot.blacklistedKernelModules = ["iosm"];
  boot.extraModulePackages = [xmm7360Pci];
  boot.kernelModules = ["xmm7360"];
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x7360", ATTR{d3cold_allowed}="0", ATTR{power/control}="on"
  '';
  environment.etc."xmm7360".text = ''
    apn=mtnirancell
    noresolv=True
    dbus=True
  '';

  systemd.services.xmm7360-connect.path = [
    pkgs.coreutils
    pkgs.kmod
  ];

  systemd.services.xmm7360-connect = {
    description = "Connect Intel XMM7360 LTE modem";
    after = [
      "NetworkManager.service"
      "systemd-modules-load.service"
      "systemd-udev-settle.service"
    ];
    wants = ["systemd-udev-settle.service"];
    requires = ["NetworkManager.service"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "300s";
      ExecStartPre = [
        "${pkgs.writeShellScript "reset-xmm7360-modem" ''
          set -u

          device=/sys/bus/pci/devices/0000:01:00.0
          if [ ! -e "$device" ]; then
            echo "xmm7360 PCI device did not appear" >&2
            exit 1
          fi

          echo 0 > "$device/d3cold_allowed" || true
          echo on > "$device/power/control" || true

          modprobe -r xmm7360 || true
          if [ -e "$device/reset" ]; then
            echo 1 > "$device/reset" || true
          fi
          modprobe xmm7360
        ''}"
        "${pkgs.writeShellScript "wait-for-xmm7360-rpc" ''
          for _ in $(seq 1 60); do
            if [ -e /dev/xmm0/rpc ] || [ -e /dev/wwan0xmmrpc0 ]; then
              exit 0
            fi
            sleep 1
          done

          echo "xmm7360 RPC device did not appear" >&2
          exit 1
        ''}"
      ];
      ExecStart = "${xmm7360Pci}/bin/xmm7360-up";
    };
  };

  services.resolved.enable = false;
  services.dnsmasq = {
    enable = true;

    settings = {
      address = [
        "/cluster.local/127.0.0.1"
        "/kiz.local/172.18.0.90"
      ];
      no-resolv = true;
      server = [
        "217.218.127.127"
        "217.218.155.155"
        "5.202.100.100"
        "8.8.8.8"
      ];
    };
  };

  networking.extraHosts = ''
    172.16.100.205 k8s.c02.kiz.ir
    172.16.100.40 grafana.prometheus.cluster.local
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
    excludePackages = [pkgs.xterm];
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
  programs.niri.enable = true;
  xdg.portal = {
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  # hardware = {
  #   enableRedistributableFirmware = true;
  #   graphics = {
  #     enable = true;
  #     enable32Bit = true;
  #   };
  # };

  # services.xserver.videoDrivers = ["amdgpu"];

  services.upower = {
    enable = true;
    usePercentageForPolicy = true;
    percentageLow = 20;
    percentageCritical = 10;
    percentageAction = 3;
    criticalPowerAction = "Suspend";
    allowRiskyCriticalPowerAction = true;
  };

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      PLATFORM_PROFILE_ON_AC = "balanced";
      PLATFORM_PROFILE_ON_BAT = "low-power";
      RUNTIME_PM_ON_AC = "auto";
      RUNTIME_PM_ON_BAT = "auto";
      SATA_LINKPWR_ON_AC = "med_power_with_dipm";
      SATA_LINKPWR_ON_BAT = "min_power";
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "on";
      USB_AUTOSUSPEND = 1;
    };
  };

  programs.nix-ld.enable = true;

  environment.shells = [pkgs.zsh];
  environment.localBinInPath = true;
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

  default.v2ray = {
    enable = true;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    corkscrew
    xmm7360Pci
  ];

  nix.settings.trusted-users = ["amin"];
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
    settings.PasswordAuthentication = false;
    # I'll disable this once I can connect.
  };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [2080];
  networking.firewall.allowedUDPPorts = [];
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
  system.stateVersion = "25.11"; # Did you read the comment?
}

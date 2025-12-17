{
  description = "Amin Mokhtari's Nixos config flake and home-manager";

  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "unstable";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "unstable";
    };

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "unstable";
    };
    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "unstable";
    };

  };

  # Snowfall Lib is a library that makes it easy to manage your Nix flake by imposing an opinionated file structure.
  # https://snowfall.org/guides/lib/quickstart/
  outputs =
    inputs:
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      src = ./.;

      snowfall.namespace = "default";

      channels-config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
        permittedInsecurePackages = [ ];
      };

      systems.modules.nixos = with inputs; [
        sops-nix.nixosModules.sops
        disko.nixosModules.disko
      ];

      # Override specific package from unstable
      # packages.x86_64-linux.noto-fonts = inputs.unstable.packages.x86_64-linux.noto-fonts;

      outputs-builder = channels: {
        # Outputs in the outputs builder are transformed to support each system. This
        # entry will be turned into multiple different outputs like `formatter.x86_64-linux.*`.
        formatter = channels.nixpkgs.alejandra;
      };
    };
}

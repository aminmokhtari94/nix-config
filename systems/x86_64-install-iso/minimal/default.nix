{ pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix"
  ];

  environment.systemPackages = with pkgs; [ neovim git networkmanager ];

  # if building a new host fill in the age key to make the key available in installer
  environment.etc."orlando-age-key.txt".text = ''
    age-some-secret-thing
  '';

  systemd.services.sshd.wantedBy = pkgs.lib.mkForce [ "multi-user.target" ];
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAGlj5STbxgr0chPN3kzTPjSZYLBixUoEoBRWCwHqA8z amin@n550jv"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN5LdF5nCTvyc7vVkcBo+KLdPChPjccy4735AfKKfSaC amin@hp-work"
  ];
}

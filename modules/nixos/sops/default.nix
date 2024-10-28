{ ... }:

{
  sops = {
    defaultSopsFile = ../../../secrets/default.yaml;
    #validateSopsFiles = false;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets.n550-amin-passwd = { neededForUsers = true; };
    secrets.wakatime-api-key = { };
  };
}

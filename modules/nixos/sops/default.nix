{ ... }:

{
  sops = {
    defaultSopsFile = ../../../secrets/default.yaml;
    validateSopsFiles = true;

    age = {
      sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;
    };

    secrets.amin-passwd = {
      neededForUsers = true;
    };
    secrets.wakatime-api-key = { };
    secrets.smug-kiz-operator = {
      owner = "amin";
      path = "/home/amin/.config/smug/kiz-operator.yml";
    };
  };
}

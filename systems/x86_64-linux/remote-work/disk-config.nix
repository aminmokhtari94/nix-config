{
  disko.devices = {
    disk.sda = {
      type = "disk";
      device = "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            size = "1G";
            type = "EF00"; # EFI System Partition
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          luksroot = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              extraOpenArgs = [ "--allow-discards" ];
              keyFile = null; # prompt at boot
              content = {
                type = "lvm_pv";
                vg = "vgroot";
              };
            };
          };
        };
      };
    };

    disk.sdb = {
      type = "disk";
      device = "/dev/sdb";
      content = {
        type = "gpt";
        partitions = {
          lukshome = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypthome";
              extraOpenArgs = [ "--allow-discards" ];
              keyFile = null;
              content = {
                type = "lvm_pv";
                vg = "vghome";
              };
            };
          };
        };
      };
    };

    lvm_vg.vgroot = {
      type = "lvm_vg";
      lvs = {
        root = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/";
          };
        };
      };
    };

    lvm_vg.vghome = {
      type = "lvm_vg";
      lvs = {
        home = {
          size = "100%FREE";
          content = {
            type = "filesystem";
            format = "ext4";
            mountpoint = "/home";
          };
        };
      };
    };
  };
}

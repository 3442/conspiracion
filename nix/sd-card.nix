{ ... }: {
  nixpkgs = {
    config.allowUnsupportedSystem = true;

    crossSystem = {
      config = "armv4-unknown-linux-gnueabi";

      gcc = {
        # > Switch "--with-arch" may not be used with switch "--with-cpu"
        # > make[1]: *** [Makefile:4315: configure-gcc] Error 1
        #arch = "armv4";

        # Ver SA110 en arch/arm/mm/Kconfig, es parecido 
        cpu = "arm810";
      };

      linux-kernel = {
        name = "taller";
        target = "uImage";
        makeFlags = [ "LOADADDR=0x01000000" ];
        autoModules = false;
        # Esto es solo para construir el toplevel del system
        baseConfig = "multi_v5_defconfig"; # "multi_v4_defconfig";
      };
    };
  };

  system.stateVersion = "22.11";

  fileSystems."/" = {
    device = "tmpfs";
    fsType = "tmpfs";
  };

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };
}

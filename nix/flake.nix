{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };

    crossSystem = "arm-linux";
    cross = import nixpkgs {
      inherit system;

      config.allowUnsupportedSystem = true;

      crossSystem = {
        config = "arm-unknown-linux-gnueabi";

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
          makeFlags = [ "LOADADDR=0x8000" ];
          autoModules = false;
          baseConfig = "taller_defconfig";
        };
      };
    };
  in {
    # Tomado de pkgs/build-support/vm/default.nix
    packages."${crossSystem}".proof-of-concept = cross.makeInitrd {
      contents = [
        {
          symlink = "/init";

          object = with cross; let
            initrdUtils = runCommand "initrd-utils"
              { nativeBuildInputs = [ buildPackages.nukeReferences ];
                allowedReferences = [ "out" ]; # prevent accidents like glibc being included in the initrd
              }
              ''
                mkdir -p $out/bin
                mkdir -p $out/lib

                # Copy what we need from Glibc.
                cp -p ${cross.glibc.out}/lib/ld-linux*.so.? $out/lib
                cp -p ${cross.glibc.out}/lib/libc.so.* $out/lib
                cp -p ${cross.glibc.out}/lib/libm.so.* $out/lib
                cp -p ${cross.glibc.out}/lib/libresolv.so.* $out/lib

                # Copy BusyBox.
                cp -pd ${cross.busybox}/bin/* $out/bin

                # Run patchelf to make the programs refer to the copied libraries.
                for i in $out/bin/* $out/lib/*; do if ! test -L $i; then nuke-refs $i; fi; done

                for i in $out/bin/*; do
                    if [ -f "$i" -a ! -L "$i" ]; then
                        echo "patching $i..."
                        patchelf --set-interpreter $out/lib/ld-linux*.so.? --set-rpath $out/lib $i || true
                    fi
                done
              '';


            path = lib.makeSearchPath "bin" [
              #bashInteractive
              #coreutils-full
              #gnugrep
              #neofetch
              #util-linux
            ];
          in writeScript "init" ''
            #!${initrdUtils}/bin/ash

            export PATH=${initrdUtils}/bin

            mkdir -p /dev /etc /proc /sys
            echo -n > /etc/fstab

            mount -t devtmpfs devtmpfs /dev
            mount -t proc none /proc
            mount -t sysfs none /sys

            exec ash
          '';
        }
      ];
    };

    devShells."${system}" = with pkgs; {
      default = mkShell {
        buildInputs = [
          ncurses
          openssl
          SDL2
        ];

        nativeBuildInputs = [
          binutils
          gcc
          gcc-arm-embedded
          gdb
          gnumake
          gtkwave
          pkg-config
          (python39.withPackages (py: [ py.numpy py.pillow py.matplotlib ]))
          (quartus-prime-lite.override { supportedDevices = [ "Cyclone V" ]; })
          verilator
        ];

        shellHook = ''
          export MAKEFLAGS="AR=gcc-ar"
          export CXXFLAGS="-O3 -flto $(pkg-config --cflags sdl2 ncursesw)"
          export LDFLAGS="-O3 -flto $(pkg-config --libs sdl2 ncursesw)"

          # <https://discourse.nixos.org/t/fonts-in-nix-installed-packages-on-a-non-nixos-system/5871/7>
          export LOCALE_ARCHIVE="${glibcLocales}/lib/locale/locale-archive"
          export FONTCONFIG_FILE="${fontconfig.out}/etc/fonts/fonts.conf"
        '';
      };

      kbuild = mkShell {
        buildInputs = [
          ncurses
        ];

        nativeBuildInputs = [
          bc
          bison
          flex
          gcc
          gcc-arm-embedded
          gnumake
          openssl # Splash de u-boot
          ubootTools
        ];

        shellHook = ''
          export CROSS_COMPILE=arm-none-eabi-
          export MAKEFLAGS="ARCH=arm O=build/taller LOADADDR=0x8000"
        '';
      };
    };
  };
}

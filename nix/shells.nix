{ pkgs }: with pkgs; {
  default = mkShell {
    buildInputs = [
      ncurses
      openssl
      SDL2
      zlib
    ];

    nativeBuildInputs = [
      binutils
      gcc
      cross.stdenv.cc.cc
      cross.stdenv.cc.bintools
      gcc-arm-embedded
      gdb
      gnumake
      gtkwave
      kermit
      meson
      ninja
      lcov
      (openocd.overrideAttrs (prev: {
        pname = "openocd-vexriscv";
        version = "0.11.0-master";

        buildInputs = prev.buildInputs ++ [ pkgs.libyaml ];
        nativeBuildInputs = [ pkgs.autoreconfHook ] ++ prev.nativeBuildInputs;

        src = pkgs.fetchFromGitHub {
          repo = "openocd_riscv";
          owner = "SpinalHDL";

          rev = "058dfa50d625893bee9fecf8d604141911fac125";
          hash = "sha256-bv8hUlZXEexUy8tzrnibNYRNb2oLRfh1xCpmalPwdqc=";
        };
      }))
      pkg-config
      (python3.withPackages (py: with py; [
        cocotb
        cocotb-bus
        find-libpython # Para cocotb
        matplotlib
        numpy
        pdoc3
        pillow
        pytest # Para cocotb
        (py.callPackage ./cocotb-coverage.nix { })
        (py.callPackage ./peakrdl/peakrdl.nix { })
        (py.callPackage ./peakrdl/peakrdl-regblock.nix { })
        (py.callPackage ./pyuvm.nix { })
      ]))
      rv32Pkgs.stdenv.cc.cc
      rv32Pkgs.stdenv.cc.bintools
      (quartus-prime-lite.override { supportedDevices = [ "Cyclone V" ]; })
      verilator
    ];

    shellHook = ''
      export CROSS_COMPILE=arm-unknown-linux-gnueabi-
      export MAKEFLAGS="AR=gcc-ar"

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
      cross.stdenv.cc.cc
      cross.stdenv.cc.bintools
      gnumake
      openssl # Splash de u-boot
      ubootTools
    ];

    shellHook = ''
      export CROSS_COMPILE=arm-unknown-linux-gnueabi-
      export MAKEFLAGS="ARCH=arm O=build/taller LOADADDR=0x8000"
    '';
  };
}

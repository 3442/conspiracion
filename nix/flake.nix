{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    devShells."${system}".default = pkgs.mkShell {
      buildInputs = with pkgs; [
        openssl
        SDL2
      ];

      nativeBuildInputs = with pkgs; [
        bc
        binutils
        bison
        flex
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
        # U-Boot
        export CROSS_COMPILE=arm-none-eabi-

        export MAKEFLAGS="AR=gcc-ar"
        export CXXFLAGS="-O3 -flto $(pkg-config --cflags sdl2)"
        export LDFLAGS="-O3 -flto $(pkg-config --libs sdl2)"

        # <https://discourse.nixos.org/t/fonts-in-nix-installed-packages-on-a-non-nixos-system/5871/7>
        export LOCALE_ARCHIVE="${pkgs.glibcLocales}/lib/locale/locale-archive"
        export FONTCONFIG_FILE="${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
      '';
    };
  };
}

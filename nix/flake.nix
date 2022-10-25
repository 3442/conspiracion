{
  outputs = { self, nixpkgs }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; config.allowUnfree = true; };
  in {
    devShells."${system}".default = pkgs.mkShell {
      buildInputs = with pkgs; [
        SDL2
      ];

      nativeBuildInputs = with pkgs; [
        binutils
        gcc
        gcc-arm-embedded
        gdb
        gnumake
        gtkwave
        pkg-config
        (python39.withPackages (py: [ py.numpy py.pillow ]))
        (quartus-prime-lite.override { supportedDevices = [ "Cyclone V" ]; })
        verilator
      ];

      shellHook = ''
        export MAKEFLAGS="AR=gcc-ar"
        export CXXFLAGS="-O3 -flto $(pkg-config --cflags sdl2)"
        export LDFLAGS="-O3 -flto $(pkg-config --libs sdl2)"
      '';
    };
  };
}

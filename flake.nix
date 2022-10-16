{
  outputs = { self, nixpkgs }: let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    devShells."x86_64-linux".default = pkgs.mkShell {
      buildInputs = [ pkgs.SDL2 ];
      nativeBuildInputs = [
        pkgs.gcc-arm-embedded
        pkgs.gdb
        pkgs.pkg-config
        (pkgs.python39.withPackages (py: [ py.numpy py.pillow ]))
      ];

      shellHook = ''
        export MAKEFLAGS="AR=gcc-ar"
        export CXXFLAGS="-O3 -flto $(pkg-config --cflags sdl2)"
        export LDFLAGS="-O3 -flto $(pkg-config --libs sdl2)"
      '';
    };
  };
}

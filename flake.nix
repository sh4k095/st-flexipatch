{
  description = "Nix flake for my fork of st";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
    };
  };

  outputs =
    inputs@{ flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;

      perSystem =
        { pkgs, self', ... }:
        {
          packages.st = pkgs.stdenv.mkDerivation {
            pname = "st";
            version = "0.9.3";

            src = ./.;

            nativeBuildInputs = with pkgs; [
              pkg-config
              ncurses
            ];

            buildInputs = with pkgs; [
              libx11
              libxft
              fontconfig
              freetype
            ];

            makeFlags = [
              "CC=${pkgs.stdenv.cc.targetPrefix}cc"
              "PREFIX=$(out)"
              "X11INC=${pkgs.libx11.dev}/include"
              "X11LIB=${pkgs.libx11}/lib"
            ];

            preInstall = ''
              export TERMINFO=$out/share/terminfo
              mkdir -p $TERMINFO
            '';

            meta = {
              description = "Simple terminal for X (flexipatch build)";
              homepage = "https://github.com/sh4k095/st-flexipatch";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.unix;
              mainProgram = "st";
            };
          };

          packages.default = self'.packages.st;

          devShells.default = pkgs.mkShell {
            inputsFrom = [ self'.packages.st ];

            MAKEFLAGS = toString [
              "X11INC=${pkgs.libx11.dev}/include"
              "X11LIB=${pkgs.libx11}/lib"
            ];
          };

          formatter = pkgs.nixfmt-tree;
        };
    };
}

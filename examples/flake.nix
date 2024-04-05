{
  description = "A devshell flake using toolkit and its nixpkgs";

  inputs = {
    toolkit.url = "github:aevox/toolkit";
    nixpkgs.follows = "toolkit/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    # Used for shell.nix
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    toolkit,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            toolkit.packages.${system}.default
          ];
        };
      }
    );
}

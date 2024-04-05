{
  description = "Fully-equipped development and operations environments";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-flux024.url = "github:NixOS/nixpkgs?rev=f76bef61369be38a10c7a1aa718782a60340d9ff";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    phps.url = "github:fossar/nix-phps";
    phps.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Used for shell.nix
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    ...
  }: let
    outputs = flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      pkgs-unstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };

      pkgs-flux024 = import inputs.nixpkgs-flux024 {
        inherit system;
      };
      flux024 = pkgs-flux024.fluxcd.overrideAttrs (oldAttrs: {
        postInstall =
          oldAttrs.postInstall
          or ""
          + ''
            mv $out/bin/flux $out/bin/flux024
            mv $out/share/zsh/site-functions/_flux $out/share/zsh/site-functions/_flux024
            mv $out/share/fish/vendor_completions.d/flux.fish $out/share/fish/vendor_completions.d/flux024.fish
            mv $out/share/bash-completion/completions/flux.bash $out/share/bash-completion/completions/flux024.bash
          '';
        installCheckPhase = ''
          $out/bin/flux024 --version | grep ${oldAttrs.version} > /dev/null
        '';
      });

      kubectl = pkgs.kubectl.overrideAttrs (oldAttrs: rec {
        version = "1.26.15";
        src = pkgs.fetchFromGitHub {
          owner = "kubernetes";
          repo = "kubernetes";
          rev = "v${version}";
          sha256 = "sha256-zegGiZM3nCxbYzwtTTgbzphAerdigSyxESpmmK3HSgI=";
        };
      });

      OpsEnv = pkgs.buildEnv {
        name = "Ops-Environment";
        paths = [
          kubectl
          flux024
          pkgs.fluxcd
          pkgs-unstable.direnv
          pkgs-unstable.jq
          pkgs-unstable.just
          pkgs-unstable.k9s
          pkgs-unstable.sops
          pkgs-unstable.kubectx
          pkgs-unstable.terraform
          pkgs-unstable.kubernetes-helm
          pkgs-unstable.istioctl
          pkgs-unstable.jinja2-cli
        ];
      };

      BackendEnv = pkgs.buildEnv {
        name = "Backend-Environment";
        paths = [
          inputs.phps.packages.${system}.php56
        ];
      };
    in {
      formatter = pkgs.alejandra;

      packages.default = OpsEnv;
      packages.OpsEnv = OpsEnv;
      packages.BackendEnv = BackendEnv;

      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          OpsEnv
        ];
      };
    });
  in
    outputs;
}

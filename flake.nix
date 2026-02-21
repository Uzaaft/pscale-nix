{
  description = "PlanetScale CLI (pscale) — built from tagged release";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        version = "0.271.0";

        src = pkgs.fetchFromGitHub {
          owner = "planetscale";
          repo = "cli";
          rev = "v${version}";
          hash = "sha256-VSHeHruqGD2cgF5XYlyeGYhcSBlGIC+lgO6Qqrhtb0Q=";
        };
      in {
        packages.default = pkgs.buildGoModule {
          pname = "pscale";
          inherit version src;

          vendorHash = "sha256-DbxciJXGcjQJZUmCbK8mFAtmKzRkWcMCWgU0SBrKTH0=";

          subPackages = ["cmd/pscale"];

          ldflags = [
            "-s"
            "-w"
            "-X main.version=v${version}"
            "-X main.date=1970-01-01T00:00:00Z"
            "-X main.commit=nixbuild"
          ];

          env.CGO_ENABLED = "0";

          meta = {
            description = "The PlanetScale CLI";
            homepage = "https://planetscale.com";
            license = pkgs.lib.licenses.asl20;
            mainProgram = "pscale";
          };
        };
      }
    );
}

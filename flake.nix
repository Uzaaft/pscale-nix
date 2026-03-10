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
        buildGoModule = pkgs.buildGo126Module;

        version = "0.274.0";

        src = pkgs.fetchFromGitHub {
          owner = "planetscale";
          repo = "cli";
          rev = "v${version}";
          hash = "sha256-N3RARfCcnw/sbLCnvm3D76Z2MIWEv4hJoTfCQwUzEoU=";
        };
      in {
        packages.default = buildGoModule rec {
          pname = "pscale";
          inherit version src;

          vendorHash = "sha256-h3w9M0Mf87nSngmvimvt8zyhPUZSysKMlnngYsL/Upw=";

          subPackages = ["cmd/pscale"];

          ldflags = [
            "-s"
            "-w"
            "-X main.version=v${version}"
            "-X main.date=1970-01-01T00:00:00Z"
            "-X main.commit=nixbuild"
          ];

          env.CGO_ENABLED = "0";

          meta = with pkgs.lib; {
            description = "The PlanetScale CLI";
            homepage = "https://planetscale.com";
            license = licenses.asl20;
            mainProgram = "pscale";
          };
        };
      }
    );
}

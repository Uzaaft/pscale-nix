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

        version = "0.272.0";

        src = pkgs.fetchFromGitHub {
          owner = "planetscale";
          repo = "cli";
          rev = "v${version}";
          hash = "sha256-1Ee8oPB2TxIrGfPVee4ptVq4eTpkVAStaXQ42q685Wk=";
        };
      in {
        packages.default = pkgs.buildGoModule rec {
          pname = "pscale";
          inherit version src;

          vendorHash = "sha256-B+tvd/SazfNn1u0pa/uWOPxpFCbX9i7jNoANKJAVVnQ";

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

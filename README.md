# pscale-nix

Nix flake for the [PlanetScale CLI](https://github.com/planetscale/cli), built from tagged releases.

## Usage

```nix
# flake.nix
{
  inputs.pscale.url = "github:uzaaft/pscale-nix";

  outputs = { pscale, ... }: {
    # Add to packages, devShells, etc.
  };
}
```

Run directly:

```sh
nix run github:uzaaft/pscale-nix -- version
```

## Updates

A GitHub Actions workflow checks for new releases every 6 hours and auto-merges update PRs.

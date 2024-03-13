# The "stamp" Nix Flake

If you have a [Nix][]-built project that has a "live at head" vibe,
you probably want to give your derivation a version number
so it can be identified and upgraded correctly.
However, placing this information directly in the output path
can cause unnecessary rebuilds during development,
wasting time and disk space.

This flake provides a function, `stamp`,
that generates a derivation with a timestamp-based `version`
that is a symlink to another derivation.
The version string is automatically generated from the `sourceInfo`
provided by a Nix Flake.

[Nix]: https://nixos.org/

## Getting Started

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
    stamp.url = "github:zombiezen/stamp.nix";
  };

  outputs = { self, nixpkgs, flake-utils, stamp, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = stamp.lib.stamp {
          inherit pkgs;
          sourceInfo = self.sourceInfo;
          wrapped = pkgs.hello;
        };
      }
    );
}
```

You can then check the version number with:

```shell
nix eval '.#default.version'
```

This will result in a string like `20240313091500`.
If the flake is being built from a clean working copy,
then the string will have the commit at the end like `20240313091500+1234cafe`.

## Reference

This flake has one function: `lib.stamp`.

| Parameter    | Description                        |
| :----------- | :--------------------------------- |
| `pkgs`       | nixpkgs for the appropriate system |
| `sourceInfo` | `self.sourceInfo` from the flake   |
| `wrapped`    | The derivation to wrap             |

`lib.stamp` returns a derivation
with the same `pname` and `meta` as the wrapped derivation.
The resulting derivation includes an additional `wrapped` attribute
that permits accessing the original derivation.

## License

[Apache 2.0](LICENSE)

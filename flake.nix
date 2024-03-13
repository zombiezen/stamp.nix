{
  description = "Library for giving a derivation a version number based on Flake sourceInfo";

  inputs = {
    nixpkgs.url = "nixpkgs";
    flake-utils.url = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    {
      lib.stamp = { pkgs, sourceInfo, wrapped }:
        let
          pname = wrapped.pname or (pkgs.lib.strings.getName wrapped.name);
          version = sourceInfo.lastModifiedDate +
            (if sourceInfo?shortRev then "+${sourceInfo.shortRev}" else "");
          name = "${pname}-${version}";
          env = {
            inherit pname version wrapped;
            inherit (wrapped) meta;

            passthru.wrapped = wrapped;
          };
        in
          pkgs.runCommandLocal name env ''
            ln -s "$wrapped" "$out"
          '';
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        checks = import ./checks.nix { inherit self pkgs; };
      }
    );
}

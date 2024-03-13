# Copyright 2024 Ross Light
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0

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
            echo "Created symlink $out to $(readlink "$out")"
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

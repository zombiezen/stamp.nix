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

{ self, pkgs }:

{
  symlinkContents = pkgs.testers.testEqualContents {
    assertion = "stamp links to the wrapped derivation";
    expected = pkgs.writeText "hello-path" ((builtins.toString pkgs.hello) + "\n");
    actual =
      let
        stamped = self.lib.stamp {
          inherit pkgs;
          wrapped = pkgs.hello;
          sourceInfo = {
            lastModifiedDate = "20240312204500";
          };
        };
      in
        pkgs.runCommandLocal "hello-stamp-symlink" { inherit stamped; } ''
          echo "Reading $stamped"
          readlink "$stamped" > "$out"
        '';
  };

  unitTests = pkgs.testers.testEqualContents {
    assertion = "stamp unit tests";

    expected = pkgs.writeText "empty-list.json" "[]";

    actual =
      let
        tests = {
          testDateOnlyName = {
            expr = (self.lib.stamp {
              inherit pkgs;
              wrapped = pkgs.hello;
              sourceInfo = {
                lastModifiedDate = "20240312204500";
              };
            }).name;
            expected = "hello-20240312204500";
          };

          testDateOnlyVersion = {
            expr = (self.lib.stamp {
              inherit pkgs;
              wrapped = pkgs.hello;
              sourceInfo = {
                lastModifiedDate = "20240312204500";
              };
            }).version;
            expected = "20240312204500";
          };

          testWithShortRevName = {
            expr = (self.lib.stamp {
              inherit pkgs;
              wrapped = pkgs.hello;
              sourceInfo = {
                lastModifiedDate = "20240312204500";
                shortRev = "deadbeef";
              };
            }).name;
            expected = "hello-20240312204500+deadbeef";
          };

          testWithShortRevVersion = {
            expr = (self.lib.stamp {
              inherit pkgs;
              wrapped = pkgs.hello;
              sourceInfo = {
                lastModifiedDate = "20240312204500";
                shortRev = "deadbeef";
              };
            }).version;
            expected = "20240312204500+deadbeef";
          };

          testWrappedAttribute = {
            expr = builtins.toString (self.lib.stamp {
              inherit pkgs;
              wrapped = pkgs.hello;
              sourceInfo = {
                lastModifiedDate = "20240312204500";
              };
            }).wrapped;
            expected = builtins.toString pkgs.hello;
          };
        };
      in
        pkgs.writeText "failures.json" (builtins.toJSON (pkgs.lib.debug.runTests tests));
  };
}

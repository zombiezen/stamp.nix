{ self, pkgs }:

{
  symlinkContents = pkgs.testers.testEqualContents {
    assertion = "stamp links to the wrapped derivation";
    expected = pkgs.runCommandLocal "hello-symlink" { x = pkgs.hello; } ''
      ln -s "$x" "$out"
    '';
    actual = self.lib.stamp {
      inherit pkgs;
      wrapped = pkgs.hello;
      sourceInfo = {
        lastModifiedDate = "20240312204500";
      };
    };
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

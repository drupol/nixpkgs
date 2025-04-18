{
  lib,
  fetchFromGitHub,
  splicePackages,
  generateSplicesForMkScope,
  newScope,
  pkgs,
  stdenv,
  maintainers,
  otherSplices,
}:
let
  officialRelease = true;
  src = fetchFromGitHub (builtins.fromJSON (builtins.readFile ./source.json));

  # A new scope, so that we can use `callPackage` to inject our own interdependencies
  # without "polluting" the top level "`pkgs`" attrset.
  # This also has the benefit of providing us with a distinct set of packages
  # we can iterate over.
  nixComponents =
    lib.makeScopeWithSplicing'
      {
        inherit splicePackages;
        inherit (nixDependencies) newScope;
      }
      {
        inherit otherSplices;
        f = import ./packaging/components.nix {
          inherit
            lib
            maintainers
            officialRelease
            pkgs
            src
            ;
        };
      };

  # The dependencies are in their own scope, so that they don't have to be
  # in Nixpkgs top level `pkgs` or `nixComponents`.
  nixDependencies =
    lib.makeScopeWithSplicing'
      {
        inherit splicePackages;
        inherit newScope; # layered directly on pkgs, unlike nixComponents above
      }
      {
        # Technically this should point to the nixDependencies set only, but
        # this is ok as long as the scopes don't intersect.
        inherit otherSplices;
        f = import ./dependencies.nix {
          inherit pkgs;
          inherit stdenv;
        };
      };
in
nixComponents.overrideSource src

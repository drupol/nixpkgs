{ buildPackages
, callPackage
, composer
, jq
, lib
, makeSetupHook
, stdenvNoCC
}:

{
  composerSetupHook = callPackage ({ }:
    makeSetupHook {
      name = "composer-setup-hook.sh";
      propagatedBuildInputs = [ composer ];
      substitutions = {
      };
    } ./composer-setup-hook.sh) {};

  composerInstallHook = callPackage ({ }:
    makeSetupHook {
      name = "composer-install-hook.sh";
      propagatedBuildInputs = [ composer jq ];
      substitutions = {
      };
    } ./composer-install-hook.sh) {};
}

{ stdenvNoCC, lib, writeTextDir, php, unzip, xz, git, makeBinaryWrapper, jq }@inputs:

let
  buildPhpProjectOverride = finalAttrs: previousAttrs:

  let
    php = finalAttrs.php or inputs.php;

    # See https://github.com/composer/composer/pull/9212
    prefix = "${builtins.replaceStrings ["-"] [""] finalAttrs.pname}";

    # See https://getcomposer.org/doc/03-cli.md#composer-home-config-json
    composerHome = let
      content = {
        config = {
          autoloader-suffix = prefix;
        };
      };
    in
      writeTextDir "/config.json" (builtins.toJSON content);
  in {
    name = finalAttrs.pname;

    nativeBuildInputs = [
      php.composerInstallHook
      git
      unzip
      xz
      makeBinaryWrapper
    ];

    buildInputs = [
      php
    ];

    strictDeps = true;
  };
in
  args: (stdenvNoCC.mkDerivation args).overrideAttrs buildPhpProjectOverride

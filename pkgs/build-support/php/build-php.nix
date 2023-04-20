{ stdenvNoCC, lib, writeTextDir, php, unzip, xz, git, makeBinaryWrapper, jq }:

let
  buildPhpProjectOverride = finalAttrs: previousAttrs:

  let
    composerLock = finalAttrs.composerLock or null;
    phpDrv = finalAttrs.php or php;
    composer = finalAttrs.composer or phpDrv.packages.composer;
    noDevArg = finalAttrs.noDev or "--no-dev";
    noScriptsArg = finalAttrs.noScripts or "--no-scripts";
    noPluginsArg = finalAttrs.noPlugins or "--no-plugins";

    prefix = builtins.replaceStrings ["-"] [""] finalAttrs.pname;

    # See https://github.com/composer/composer/pull/9212
    apcuAutoloaderPrefixArg = "--apcu-autoloader-prefix=${prefix}";

    # See https://getcomposer.org/doc/03-cli.md#composer-home-config-json
    composerHome = let
      content.config.autoloader-suffix = prefix;
    in
      writeTextDir "/config.json" (builtins.toJSON content);

    vendor = stdenvNoCC.mkDerivation (finalVendorAttrs: {
      inherit noDevArg noScriptsArg noPluginsArg apcuAutoloaderPrefixArg;
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-vendor";

      # See https://github.com/NixOS/nix/issues/6660
      dontPatchShebangs = true;

      nativeBuildInputs = [
        composer
        php.composerHooks.composerSetupHook
      ];

      composerLock = finalAttrs.composerLock or null;

      configurePhase = ''
        runHook preConfigure

        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        runHook postInstall
      '';

      strictDeps = true;

      outputHashMode = "recursive";
      outputHashAlgo = if (finalAttrs ? vendorHash && finalAttrs.vendorHash != "") then null else "sha256";
      outputHash = finalAttrs.vendorHash or "";
    });
  in {
    inherit noDevArg noScriptsArg noPluginsArg apcuAutoloaderPrefixArg;

    prefix = "${builtins.replaceStrings ["-"] [""] finalAttrs.pname}";

    nativeBuildInputs = [
      composer
      php.composerHooks.composerInstallHook
    ];

    composerVendor = vendor;

    buildInputs = [
      phpDrv
    ];

    configurePhase = ''
      runHook preConfigure

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      runHook postInstall
    '';

    strictDeps = true;
  };
in
  args: (stdenvNoCC.mkDerivation args).overrideAttrs buildPhpProjectOverride

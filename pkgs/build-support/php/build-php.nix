{ stdenvNoCC, lib, writeTextDir, php }:

let
  buildPhpProjectOverride = finalAttrs: previousAttrs:

  let
    phpDrv = finalAttrs.php or php;
    composer = finalAttrs.composer or phpDrv.packages.composer;

    prefix = builtins.replaceStrings ["-"] [""] finalAttrs.pname;

    # See https://github.com/composer/composer/pull/9212
    apcuAutoloaderPrefixArg = "--apcu-autoloader-prefix=${prefix}";

    # See https://getcomposer.org/doc/03-cli.md#composer-home-config-json
    composerHome = let
      content.config.autoloader-suffix = prefix;
    in
      writeTextDir "/config.json" (builtins.toJSON content);

    vendor = stdenvNoCC.mkDerivation (finalVendorAttrs: {
      inherit apcuAutoloaderPrefixArg;
      inherit (finalAttrs) version src;
      pname = "${finalAttrs.pname}-vendor";

      # See https://github.com/NixOS/nix/issues/6660
      dontPatchShebangs = true;

      nativeBuildInputs = [
        composer
        php.composerHooks.composerSetupHook
      ];

      composerLock = finalAttrs.composerLock or null;

      # Should we keep these empty phases?
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
    inherit apcuAutoloaderPrefixArg;

    prefix = "${builtins.replaceStrings ["-"] [""] finalAttrs.pname}";

    nativeBuildInputs = [
      composer
      php.composerHooks.composerInstallHook
    ];

    composerVendor = vendor;

    buildInputs = [
      phpDrv
    ];

      # Should we keep these empty phases?
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

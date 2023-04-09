{ stdenvNoCC, lib, writeTextDir, php, unzip, xz, git, makeBinaryWrapper, jq }@inputs:

let
  buildPhpProjectOverride = finalAttrs: previousAttrs:

  let
    composerLock = finalAttrs.composerLock or null;
    php = finalAttrs.php or inputs.php;
    composer = finalAttrs.composer or inputs.php.packages.composer;
    noDev = finalAttrs.noDev or true;
    noScripts = finalAttrs.noScripts or true;
    noPlugins = finalAttrs.noPlugins or true;

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

    vendor = stdenvNoCC.mkDerivation (finalVendorAttrs: {
      src = finalAttrs.src;
      version = finalAttrs.src.rev;
      pname = "${finalAttrs.pname}-vendor";

      # See https://github.com/NixOS/nix/issues/6660
      dontPatchShebangs = true;

      nativeBuildInputs = [
        composer
        git
        unzip
        xz
      ];

      strictDeps = true;

      configurePhase = ''
        runHook preConfigure

        ${lib.optionalString (composerLock != null) "cp ${composerLock} composer.lock"}

        if [ ! -f "composer.lock" ]
        then
          echo "No composer.lock file found"
          exit 1
        fi

        mkdir -p cache

        runHook postConfigure
      '';

      buildPhase = ''
        runHook preBuild

        COMPOSER_CACHE_DIR=cache \
        COMPOSER_HOME=${composerHome} \
        composer install \
          ${lib.optionalString (noDev == true) "--no-dev"} \
          ${lib.optionalString (noScripts == true) "--no-scripts"} \
          ${lib.optionalString (noPlugins == true) "--no-plugins"} \
          --download-only

        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out
        cp composer.lock $out/
        cp -ar cache/ $out/

        runHook postInstall
      '';

      outputHashMode = "recursive";
      outputHashAlgo = if (finalAttrs ? vendorHash && finalAttrs.vendorHash != "") then null else "sha256";
      outputHash = finalAttrs.vendorHash or "";
    });
  in {
    name = finalAttrs.pname;

    nativeBuildInputs = [
      composer
      git
      unzip
      xz
      makeBinaryWrapper
    ];

    buildInputs = [
      php
    ];

    strictDeps = true;

    configurePhase = ''
      runHook preConfigure

      cp -fr ${vendor}/* .
      chmod 777 cache -R

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      COMPOSER_DISABLE_NETWORK=1 \
      COMPOSER_CACHE_DIR=cache \
      composer install \
        --apcu-autoloader-prefix=${prefix} \
        ${lib.optionalString (noDev == true) "--no-dev"} \
        ${lib.optionalString (noScripts == true) "--no-scripts"} \
        ${lib.optionalString (noPlugins == true) "--no-plugins"} \
        --no-interaction \
        --optimize-autoloader

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/php/${finalAttrs.pname} $out/bin
      rm -rf cache
      cp -r . $out/share/php/${finalAttrs.pname}/

      ${jq}/bin/jq -r -c '.bin | .[]' composer.json | while read bin; do
        ln -s $out/share/php/${finalAttrs.pname}/$bin $out/bin/$(basename $bin)
      done

      runHook postInstall
    '';
  };
in
  args: (stdenvNoCC.mkDerivation args).overrideAttrs buildPhpProjectOverride

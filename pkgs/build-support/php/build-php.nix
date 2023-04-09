{ stdenvNoCC, lib, writeTextDir, php, unzip, xz, git, makeBinaryWrapper, jq }:

let
  buildPhpProjectOverride = finalAttrs: previousAttrs:

  let
    composerLock = finalAttrs.composerLock or null;
    phpDrv = finalAttrs.php or php;
    composer = finalAttrs.composer or phpDrv.packages.composer;
    noDev = finalAttrs.noDev or true;
    noScripts = finalAttrs.noScripts or true;
    noPlugins = finalAttrs.noPlugins or true;

    # See https://github.com/composer/composer/pull/9212
    prefix = "${builtins.replaceStrings ["-"] [""] finalAttrs.pname}";

    # See https://getcomposer.org/doc/03-cli.md#composer-home-config-json
    composerHome = let
      content.config.autoloader-suffix = prefix;
    in
      writeTextDir "/config.json" (builtins.toJSON content);

    vendor = stdenvNoCC.mkDerivation (finalVendorAttrs: {
      inherit (finalAttrs) version src;
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

        if [[ ! -f "composer.lock" ]]; then
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
          ${lib.optionalString noDev "--no-dev"} \
          ${lib.optionalString noScripts "--no-scripts"} \
          ${lib.optionalString noPlugins "--no-plugins"} \
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
    nativeBuildInputs = [
      composer
      git
      jq
      makeBinaryWrapper
      unzip
      xz
    ];

    buildInputs = [
      phpDrv
    ];

    strictDeps = true;

    configurePhase = ''
      runHook preConfigure

      cp -fr ${vendor}/* .
      chmod +w cache -R

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      COMPOSER_DISABLE_NETWORK=1 \
      COMPOSER_CACHE_DIR=cache \
      composer install \
        --apcu-autoloader-prefix=${prefix} \
        ${lib.optionalString noDev "--no-dev"} \
        ${lib.optionalString noScripts "--no-scripts"} \
        ${lib.optionalString noPlugins "--no-plugins"} \
        --no-interaction \
        --optimize-autoloader

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/php/${finalAttrs.pname}
      rm -rf cache
      cp -r . $out/share/php/${finalAttrs.pname}/

      jq -r -c 'try .bin[]' composer.json | while read bin; do
        mkdir -p $out/bin
        ln -s $out/share/php/${finalAttrs.pname}/$bin $out/bin/$(basename $bin)
      done

      runHook postInstall
    '';
  };
in
  args: (stdenvNoCC.mkDerivation args).overrideAttrs buildPhpProjectOverride

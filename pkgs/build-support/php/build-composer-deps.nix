{ stdenvNoCC, lib, writeTextDir, php, unzip, xz, git, makeBinaryWrapper, jq }:

let
  buildComposerDepsOverride = finalAttrs: previousAttrs:

  let
    composerLock = finalAttrs.composerLock or null;
    phpDrv = finalAttrs.php or php;
    composer = finalAttrs.composer or phpDrv.packages.composer;

    # See https://github.com/composer/composer/pull/9212
    prefix = "${builtins.replaceStrings ["-"] [""] finalAttrs.pname}";

    # See https://getcomposer.org/doc/03-cli.md#composer-home-config-json
    composerHome = let
        content.config.autoloader-suffix = prefix;
      in
        writeTextDir "/config.json" (builtins.toJSON content);
  in {
    name = "composer-build-deps";

    # See https://github.com/NixOS/nix/issues/6660
    dontPatchShebangs = true;

    nativeBuildInputs = [
      composer
      php.composerHooks.composerSetupHook
    ];

    strictDeps = true;

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

    outputHashMode = "recursive";
    outputHashAlgo = if (finalAttrs ? vendorHash && finalAttrs.vendorHash != "") then null else "sha256";
    outputHash = finalAttrs.vendorHash or "";
  };
in
  args: (stdenvNoCC.mkDerivation args).overrideAttrs buildComposerDepsOverride

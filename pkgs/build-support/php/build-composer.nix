{ stdenvNoCC, lib, writeTextDir, php, unzip, xz, git }@inputs:

let
  buildPhpComposerOverride = finalAttrs: previousAttrs:

  let
    composerLock = finalAttrs.composerLock or null;
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
  in {
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

    outputHashMode = "recursive";
    outputHashAlgo = if (finalAttrs ? hash && finalAttrs.hash != "") then null else "sha256";
    outputHash = finalAttrs.hash or "";
};
in
  args: (stdenvNoCC.mkDerivation args).overrideAttrs buildPhpComposerOverride

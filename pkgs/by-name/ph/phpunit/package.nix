{
  lib,
  fetchFromGitHub,
  nix-update-script,
  php,
  versionCheckHook,
}:

php.buildComposerProject2 (finalAttrs: {
  pname = "phpunit";
  version = "12.5.1";

  src = fetchFromGitHub {
    owner = "sebastianbergmann";
    repo = "phpunit";
    tag = finalAttrs.version;
    hash = "sha256-fbHHoqCHL3KizoVRWm+Dj+nfb5CLF8SGfMc1D2OjbHY=";
  };

  vendorHash = "sha256-p8UQVOfcx9iOX2KuSPazqZe/0kZiFBEcbL5f9unqEFg=";

  passthru = {
    updateScript = nix-update-script { };
  };

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "--version";

  meta = {
    changelog = "https://github.com/sebastianbergmann/phpunit/blob/${finalAttrs.version}/ChangeLog-${lib.versions.majorMinor finalAttrs.version}.md";
    description = "PHP Unit Testing framework";
    homepage = "https://phpunit.de";
    license = lib.licenses.bsd3;
    mainProgram = "phpunit";
    maintainers = with lib.maintainers; [
      onny
      patka
    ];
  };
})

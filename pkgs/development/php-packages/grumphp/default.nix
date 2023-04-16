{ fetchFromGitHub, lib, php }:

php.buildPhpProject (finalAttrs: {
  pname = "grumphp";
  version = "1.15.0";

  src = fetchFromGitHub {
    owner = "phpro";
    repo = "grumphp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EIGIoImRKR1Mc7oFXIzuLD3S1zx9WtHwDX0ST1T4BH0=";
  };

  # TODO: Open a PR against https://github.com/phpro/grumphp
  # Missing `composer.lock` from the repository.
  composerDeps = php.buildComposerCacheDir {
    inherit (finalAttrs) src;
    name = "${finalAttrs.pname}-${finalAttrs.version}";
    hash = "sha256-DsKYccvg4ue2K9Z3DTQzm6gDs/qqbfX2FhITSIHniAk=";
  };

  meta = with lib; {
    changelog = "https://github.com/phpro/grumphp/releases/tag/v${finalAttrs.version}";
    description = "A PHP code-quality tool";
    homepage = "https://github.com/phpro/grumphp";
    license = licenses.mit;
    maintainers = teams.php.members;
  };
})

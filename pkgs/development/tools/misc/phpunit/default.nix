{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "phpunit";
  version = "10.1.0";

  src = fetchFromGitHub {
    owner = "sebastianbergmann";
    repo = "phpunit";
    rev = finalAttrs.version;
    hash = "sha256-VcQRSss2dssfkJ+iUb5qT+FJ10GHiFDzySigcmuVI+8=";
  };

  # TODO: Open a PR against https://github.com/sebastianbergmann/phpunit
  # Missing `composer.lock` from the repository.
  composerLock = ./composer.lock;
  vendorHash = "sha256-9vW7ybo/+n/+XjDAwHC8kYJddaZAjGWNE+R+vi1u1mU=";

  meta = with lib; {
    description = "PHP Unit Testing framework";
    license = licenses.bsd3;
    homepage = "https://phpunit.de";
    changelog = "https://github.com/sebastianbergmann/phpunit/blob/${finalAttrs.version}/ChangeLog-${lib.versions.majorMinor finalAttrs.version}.md";
    maintainers = with maintainers; [ onny ] ++ teams.php.members;
  };
})

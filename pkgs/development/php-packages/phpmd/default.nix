{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "phpmd";
  version = "2.13.0";

  src = fetchFromGitHub {
    owner = "phpmd";
    repo = "phpmd";
    rev = finalAttrs.version;
    hash = "sha256-4ZBtoAJC8nnfwZavIVDt33+yKQ1ZNLBym/UT11ciax8=";
  };

  # TODO: Open a PR against https://github.com/phpmd/phpmd
  # Missing `composer.lock` from the repository.
  composerLock = ./composer.lock;
  vendorHash = "sha256-cT2GUuy2WC5eig/qUBfbfj2WN579zfQPrJ9O/3744jI=";

  meta = with lib; {
    changelog = "https://github.com/phpmd/phpmd/releases/tag/${finalAttrs.version}";
    description = "PHP code quality analyzer";
    license = licenses.bsd3;
    homepage = "https://phpmd.org/";
    maintainers = teams.php.members;
  };
})

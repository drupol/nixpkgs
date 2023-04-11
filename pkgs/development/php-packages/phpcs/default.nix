{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "phpcs";
  version = "3.7.2";

  src = fetchFromGitHub {
    owner = "squizlabs";
    repo = "PHP_CodeSniffer";
    rev = finalAttrs.version;
    hash = "sha256-EJF9e8gyUy5SZ+lmyWFPAabqnP7Fy5t80gfXWWxLpk8=";
  };

  # TODO: Open a PR against https://github.com/squizlabs/PHP_CodeSniffer
  # Missing `composer.lock` from the repository.
  composerLock = ./composer.lock;
  vendorHash = "sha256-9IOyxL0JZe1fNtMXl07sDt6ZxRVmTbBBKu4TIquUnYc=";

  meta = with lib; {
    changelog = "https://github.com/squizlabs/PHP_CodeSniffer/releases/tag/${finalAttrs.version}";
    description = "PHP coding standard tool";
    license = licenses.bsd3;
    homepage = "https://squizlabs.github.io/PHP_CodeSniffer/";
    maintainers = with maintainers; [ javaguirre ] ++ teams.php.members;
  };
})

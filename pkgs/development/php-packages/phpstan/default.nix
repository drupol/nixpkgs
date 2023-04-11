{ fetchFromGitHub, lib, php }:

php.buildPhpProject (finalAttrs: {
  pname = "phpstan";
  version = "1.10.11";

  src = fetchFromGitHub {
    owner = "phpstan";
    repo = "phpstan-src";
    rev = finalAttrs.version;
    hash = "sha256-h2m0yq2H+g3d+jAqJ+ex5/5MX2Z8VHA02/rHLKisdtw=";
  };

  vendorHash = "sha256-otbuK9BbPWtITSzeWVSSas7ijiZrKeDF23MWPmYR5vw=";

  meta = with lib; {
    changelog = "https://github.com/phpstan/phpstan/releases/tag/${finalAttrs.version}";
    description = "PHP Static Analysis Tool";
    longDescription = ''
      PHPStan focuses on finding errors in your code without actually
      running it. It catches whole classes of bugs even before you write
      tests for the code. It moves PHP closer to compiled languages in the
      sense that the correctness of each line of the code can be checked
      before you run the actual line.
    '';
    license = licenses.mit;
    homepage = "https://github.com/phpstan/phpstan";
    maintainers = teams.php.members;
  };
})

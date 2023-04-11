{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "phive";
  version = "0.15.2";

  src = fetchFromGitHub {
    owner = "phar-io";
    repo = "phive";
    rev = finalAttrs.version;
    hash = "sha256-K/YZOGANcefjfdFY1XYEQknm0bPRorlRnNGC7dEegZ0=";
  };

  vendorHash = "sha256-W3Uxy31MJ667wHaCldY8pn3Jv4cLBQ5ghyxUuefNcXU=";

  meta = with lib; {
    changelog = "https://github.com/phar-io/phive/releases/tag/${finalAttrs.version}";
    description = "The Phar Installation and Verification Environment (PHIVE)";
    homepage = "https://github.com/phar-io/phive";
    license = licenses.bsd3;
    maintainers = with maintainers; teams.php.members;
  };
})

{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "deployer";
  version = "7.3.1";

  src = fetchFromGitHub {
    owner = "deployphp";
    repo = "deployer";
    rev = "v${finalAttrs.version}^";
    hash = "sha256-bsJcozAVvRXUNdxRdBh5SB6qESUSXkkPeEWF50IiboQ=";
  };

  vendorHash = "sha256-oTmzqiOymKoiKp1A7XZ3aYYwZ6kAH9T+4Z2yiY0c/sk=";

  meta = with lib; {
    description = "A deployment tool for PHP";
    license = licenses.mit;
    homepage = "https://deployer.org/";
    mainProgram = "dep";
    maintainers = with maintainers; teams.php.members;
  };
})

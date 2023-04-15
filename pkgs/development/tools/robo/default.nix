{ lib, fetchFromGitHub, php80 }:

php80.buildPhpProject (finalAttrs: {
  pname = "robo";
  version = "3.0.4";

  src = fetchFromGitHub {
    owner = "consolidation";
    repo = "robo";
    rev = finalAttrs.version;
    hash = "sha256-d6IxE1pHfNAIaW2jRwl/7bweNFaovV0cTQSF2CwvD1Q=";
  };

  vendorHash = "sha256-iCo2MpkhEsZQuOvsgzfmuP7u+DZu2qEykyZzzWoznow=";

  meta = with lib; {
    description = "Modern task runner for PHP";
    license = licenses.mit;
    homepage = "https://github.com/consolidation/robo";
    maintainers = with maintainers; teams.php.members;
  };
})

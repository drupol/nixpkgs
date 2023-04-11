{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "phpactor";
  version = "2023.04.10";

  src = fetchFromGitHub {
    owner = "phpactor";
    repo = "phpactor";
    rev = finalAttrs.version;
    hash = "sha256-nEerwOrXsghdLxG1iVK5pNgLkYFJWqmfL4HMRkjiYdI=";
  };

  vendorHash = "sha256-dR+Y3rf47nwJQ1+bYBO+ap/w/0755/qHwTZWBVkMzb4=";

  meta = with lib; {
    description = "Mainly a PHP Language Server";
    homepage = "https://github.com/phpactor/phpactor";
    license = licenses.mit;
    maintainers = with maintainers; [ ryantm ] ++ teams.php.members;
  };
})

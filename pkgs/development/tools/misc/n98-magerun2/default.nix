{ lib, fetchFromGitHub, php80 }:

php80.buildPhpProject (finalAttrs: {
  pname = "n98-magerun2";
  version = "7.0.3";

  src = fetchFromGitHub {
    owner = "netz98";
    repo = "n98-magerun2";
    rev = finalAttrs.version;
    sha256 = "sha256-nONON259eYPtuJLaBOdMfZ62NVc1e8BYHKhpsqxoLJ8=";
  };

  vendorHash = "sha256-0vU/kSK0gxjBA7XMrpwcnXpNNXRCZz64YVxrD7F/6v0=";

  meta = with lib; {
    description = "The swiss army knife for Magento2 developers";
    license = licenses.mit;
    homepage = "https://magerun.net/";
    changelog = "https://magerun.net/category/magerun/";
    maintainers = teams.php.members;
  };
})

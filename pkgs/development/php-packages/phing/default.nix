{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "phing";
  version = "3.0.0-RC4";

  src = fetchFromGitHub {
    owner = "phingofficial";
    repo = "phing";
    rev = finalAttrs.version;
    hash = "sha256-qaduCfAWVgqQFNmuH3nxqtv92RWdXY0g40oVlh88zyE=";
  };

  # TODO: Open a PR against https://github.com/phingofficial/phing
  # Their `composer.lock` is out of date therefore, we need to provide one
  composerLock = ./composer.lock;
  vendorHash = "sha256-ZvDkTT7d/1JiKI+xA4k3ioNQHhHjcC2ItOHkU7q44lQ=";

  meta = with lib; {
    description = "PHing Is Not GNU make; it's a PHP project build system or build tool based on Apache Ant";
    license = licenses.lgpl3;
    homepage = "https://github.com/phingofficial/phing";
    maintainers = with maintainers; teams.php.members;
  };
})

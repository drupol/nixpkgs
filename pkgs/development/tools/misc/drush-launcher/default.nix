{ lib, stdenv, fetchurl, fetchFromGitHub, php, which, makeWrapper, bash, coreutils, ncurses }:

php.buildPhpProject (finalAttrs: {
  pname = "drush-launcher";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "drush-ops";
    repo = "drush-launcher";
    rev = finalAttrs.version;
    sha256 = "sha256-bJaKDu5iNSI+QOCY2cZEVSsV0lSOkLB1eQ9Y9CRU7Pc=";
  };

  vendorHash = "sha256-ZERaC2AyR1XABJH2Lu0o7SpZwnVDJWCtqY/soQZgyck=";

  meta = with lib; {
    description = "Command-line shell and Unix scripting interface for Drupal";
    homepage = "https://github.com/drush-ops/drush";
    license = licenses.gpl2;
    maintainers = with maintainers; [ lovek323 ];
    platforms = platforms.all;
  };
})

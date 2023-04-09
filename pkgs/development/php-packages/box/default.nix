{ fetchFromGitHub, lib, php }:

php.buildPhpProject (finalAttrs: {
  pname = "box";
  version = "4.3.8";

  src = fetchFromGitHub {
    owner = "box-project";
    repo = "box";
    rev = finalAttrs.version;
    hash = "sha256-v1J84nqaX36DrLLH5kld+8NIymqtt5/5nJWJNCBVFRE=";
  };

  php = (php.buildEnv {
    extraConfig = ''
      phar.readonly=0
    '';
  });

  vendorHash = "sha256-cA9nuB+72N2tpYrojANOgYslOMWYeNe/+F41q211rTk=";

  meta = with lib; {
    changelog = "https://github.com/box-project/box/releases/tag/${version}";
    description = "An application for building and managing Phars";
    license = licenses.mit;
    homepage = "https://github.com/box-project/box";
    maintainers = with maintainers; [ jtojnar ] ++ teams.php.members;
  };
})

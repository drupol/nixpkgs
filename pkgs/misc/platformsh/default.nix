{ lib, fetchFromGitHub, php }:

php.buildPhpProject (finalAttrs: {
  pname = "platformsh";
  version = "4.4.1";

  src = fetchFromGitHub {
    owner = "platformsh";
    repo = "legacy-cli";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1DCv4M7nCDrBeMoULO8kWQkMgEYGZmBaBfbsVpMCOVA=";
  };

  vendorHash = "sha256-3xhb1aT8US+nYAMFtiO4w2pZlkEB7PSojjQuDRgkN+8=";

  meta = with lib; {
    description = "The unified tool for managing your Platform.sh services from the command line.";
    homepage = "https://github.com/platformsh/platformsh-cli";
    license = licenses.mit;
    maintainers = with maintainers; [ shyim ];
    mainProgram = "platform";
    platforms = platforms.all;
  };
})

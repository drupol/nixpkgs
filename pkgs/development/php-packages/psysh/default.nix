{ fetchFromGitHub, lib, php }:

php.buildPhpProject (finalAttrs: {
  pname = "psysh";
  version = "0.11.15";

  src = fetchFromGitHub {
    owner = "bobthecow";
    repo = "psysh";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ERHnmTC3C5ylrZrG4nRkp78B5bEluqnyZrW7g+ZRtyM=";
  };

  # TODO: Open a PR against https://github.com/bobthecow/psysh
  # Missing `composer.lock` from the repository.
  composerLock = ./composer.lock;

  vendorHash = "sha256-jpqCPV/ARlFdZF5h8BYgOjhJGiyIWv0J9CDEAH7o8o8=";

  meta = with lib; {
    changelog = "https://github.com/bobthecow/psysh/releases/tag/v${finalAttrs.version}";
    description = "PsySH is a runtime developer console, interactive debugger and REPL for PHP.";
    license = licenses.mit;
    homepage = "https://psysh.org/";
    maintainers = teams.php.members;
  };
})

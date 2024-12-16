{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "precisely";
  version = "0.1.9";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mwilliamson";
    repo = "python-precisely";
    rev = version;
    hash = "sha256-jvvRreSGpRgDk1bbqC8Z/UEfvxwKilfc/sm7nxdJU6k=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "precisely"
  ];

  meta = {
    description = "Matcher library for Python";
    homepage = "https://github.com/mwilliamson/python-precisely";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ drupol ];
  };
}

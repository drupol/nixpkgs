{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
  precisely,
}:

buildPythonPackage rec {
  pname = "funk";
  version = "0.5.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mwilliamson";
    repo = "funk";
    rev = version;
    hash = "sha256-dEq3zyA8rtNt0sui2TfQ3OUSCZ0XDMOdthcqt/QrCsU=";
  };

  build-system = [
    setuptools
    wheel
  ];

  dependencies = [
    precisely
  ];

  pythonImportsCheck = [
    "funk"
  ];

  meta = {
    description = "A mocking framework for Python, influenced by JMock";
    homepage = "https://github.com/mwilliamson/funk";
    changelog = "https://github.com/mwilliamson/funk/blob/${src.rev}/NEWS";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ ];
  };
}

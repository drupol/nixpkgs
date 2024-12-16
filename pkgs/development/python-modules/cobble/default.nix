{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  wheel,
}:

buildPythonPackage rec {
  pname = "cobble";
  version = "0.1.4";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mwilliamson";
    repo = "python-cobble";
    rev = version;
    hash = "sha256-xi6cCSUnMYc5Tp6+TQlC9Oo9kpam5C7QGCul/IoTW1k=";
  };

  build-system = [
    setuptools
    wheel
  ];

  pythonImportsCheck = [
    "cobble"
  ];

  meta = {
    description = "Create Python data objects";
    homepage = "https://github.com/mwilliamson/python-cobble";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ drupol ];
  };
}

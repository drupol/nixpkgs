{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  cobble,
  funk,
  pytestCheckHook,
  spur,
  tempman,
}:

buildPythonPackage rec {
  pname = "mammoth";
  version = "1.8.0";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "mwilliamson";
    repo = "python-mammoth";
    rev = version;
    hash = "sha256-mIvzEyKpy1j7tZti+QTXgsbqqZAhYs7N+p5sQFsLhBg=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'read("README")' '""'
  '';

  build-system = [
    setuptools
  ];

  dependencies = [
    cobble
  ];

  pythonImportsCheck = [
    "mammoth"
  ];

  nativeCheckInputs = [
    funk
    pytestCheckHook
    spur
    tempman
  ];

  disabledTestPaths = [
    "tests/cli_tests.py"
  ];

  meta = {
    description = "Convert Word documents (.docx files) to HTML";
    homepage = "https://github.com/mwilliamson/python-mammoth";
    changelog = "https://github.com/mwilliamson/python-mammoth/blob/${src.rev}/NEWS";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ drupol ];
  };
}

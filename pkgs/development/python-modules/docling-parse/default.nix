{
  lib,
  buildPythonPackage,
  fetchFromGitHub,
  cmake,
  pkg-config,
  cxxopts,
  poetry-core,
  pybind11,
  tabulate,
  zlib,
  nlohmann_json,
  utf8cpp,
  libjpeg,
  qpdf,
  loguru-cpp,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "docling-parse";
  version = "2.0.2";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "DS4SD";
    repo = "docling-parse";
    rev = "v${version}";
    hash = "sha256-unXGmMp5xyRCqSoFmqcQAZOBzpE0EzgEEBIfZUHhRcQ=";
  };

  dontUseCmakeConfigure = true;

  build-system = [
    cmake
    poetry-core
    pybind11
    pkg-config
  ];

  env.NIX_CFLAGS_COMPILE = [
    "-I${lib.getDev utf8cpp}/include/utf8cpp"
  ];

  buildInputs = [
    cxxopts
    libjpeg
    loguru-cpp
    nlohmann_json
    qpdf
    utf8cpp
    zlib
  ];

  env.USE_SYSTEM_DEPS = true;

  cmakeFlags = [
    "-DUSE_SYSTEM_DEPS=True"
  ];

  dependencies = [
    tabulate
  ];

  pythonImportsCheck = [
    "docling_parse"
  ];

  nativeCheckInputs = [
    pytestCheckHook
  ];

  meta = {
    changelog = "https://github.com/DS4SD/docling-parse/blob/${src.rev}/CHANGELOG.md";
    description = "Simple package to extract text with coordinates from programmatic PDFs";
    homepage = "https://github.com/DS4SD/docling-parse";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ drupol ];
  };
}

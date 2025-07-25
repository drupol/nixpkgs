{
  lib,
  stdenv,
  cmake,
  libGLU,
  libGL,
  zlib,
  wxGTK,
  gtk3,
  libX11,
  gettext,
  glew,
  glm,
  cairo,
  curl,
  openssl,
  boost,
  pkg-config,
  doxygen,
  graphviz,
  libpthreadstubs,
  libXdmcp,
  unixODBC,
  libgit2,
  libsecret,
  libgcrypt,
  libgpg-error,
  ninja,

  util-linux,
  libselinux,
  libsepol,
  libthai,
  libdatrie,
  libxkbcommon,
  libepoxy,
  dbus,
  at-spi2-core,
  libXtst,
  pcre2,
  libdeflate,

  swig,
  python,
  wxPython,
  opencascade-occt_7_6,
  libngspice,
  valgrind,
  protobuf_29,
  nng,

  stable,
  testing,
  baseName,
  kicadSrc,
  kicadVersion,
  withNgspice,
  withScripting,
  withI18n,
  debug,
  sanitizeAddress,
  sanitizeThreads,
}:

assert lib.assertMsg (
  !(sanitizeAddress && sanitizeThreads)
) "'sanitizeAddress' and 'sanitizeThreads' are mutually exclusive, use one.";
assert testing -> !stable -> throw "testing implies stable and cannot be used with stable = false";

let
  opencascade-occt = opencascade-occt_7_6;
  inherit (lib) optional optionals optionalString;
in
stdenv.mkDerivation rec {
  pname = "kicad-base";
  version = if (stable) then kicadVersion else builtins.substring 0 10 src.rev;

  src = kicadSrc;

  patches = [
    # upstream issue 12941 (attempted to upstream, but appreciably unacceptable)
    ./writable.patch
    # https://gitlab.com/kicad/code/kicad/-/issues/15687
    ./runtime_stock_data_path.patch
  ];

  # tagged releases don't have "unknown"
  # kicad testing and nightlies use git describe --dirty
  # nix removes .git, so its approximated here
  postPatch = lib.optionalString (!stable || testing) ''
    substituteInPlace cmake/KiCadVersion.cmake \
      --replace "unknown" "${builtins.substring 0 10 src.rev}"

    substituteInPlace cmake/CreateGitVersionHeader.cmake \
      --replace "0000000000000000000000000000000000000000" "${src.rev}"
  '';

  preConfigure = optional (debug) ''
    export CFLAGS="''${CFLAGS:-} -Og -ggdb"
    export CXXFLAGS="''${CXXFLAGS:-} -Og -ggdb"
  '';

  cmakeFlags = [
    "-DKICAD_USE_EGL=ON"
    "-DOCC_INCLUDE_DIR=${opencascade-occt}/include/opencascade"
    # https://gitlab.com/kicad/code/kicad/-/issues/17133
    "-DCMAKE_CTEST_ARGUMENTS='--exclude-regex;qa_spice'"
    "-DKICAD_USE_CMAKE_FINDPROTOBUF=OFF"
  ]
  ++ optional (
    stdenv.hostPlatform.system == "aarch64-linux"
  ) "-DCMAKE_CTEST_ARGUMENTS=--exclude-regex;'qa_spice|qa_cli'"
  ++ optional (stable && !withNgspice) "-DKICAD_SPICE=OFF"
  ++ optionals (!withScripting) [
    "-DKICAD_SCRIPTING_WXPYTHON=OFF"
  ]
  ++ optionals (withI18n) [
    "-DKICAD_BUILD_I18N=ON"
  ]
  ++ optionals (!doInstallCheck) [
    "-DKICAD_BUILD_QA_TESTS=OFF"
  ]
  ++ optionals (debug) [
    "-DKICAD_STDLIB_DEBUG=ON"
    "-DKICAD_USE_VALGRIND=ON"
  ]
  ++ optionals (sanitizeAddress) [
    "-DKICAD_SANITIZE_ADDRESS=ON"
  ]
  ++ optionals (sanitizeThreads) [
    "-DKICAD_SANITIZE_THREADS=ON"
  ];

  cmakeBuildType = if debug then "Debug" else "Release";

  nativeBuildInputs = [
    cmake
    ninja
    doxygen
    graphviz
    pkg-config
    libgit2
    libsecret
    libgcrypt
    libgpg-error
  ]
  # wanted by configuration on linux, doesn't seem to affect performance
  # no effect on closure size
  ++ optionals (stdenv.hostPlatform.isLinux) [
    util-linux
    libselinux
    libsepol
    libthai
    libdatrie
    libxkbcommon
    libepoxy
    dbus
    at-spi2-core
    libXtst
    pcre2
  ];

  buildInputs = [
    libGLU
    libGL
    zlib
    libX11
    wxGTK
    gtk3
    libXdmcp
    gettext
    glew
    glm
    libpthreadstubs
    cairo
    curl
    openssl
    boost
    swig
    python
    unixODBC
    libdeflate
    opencascade-occt
    protobuf_29

    # This would otherwise cause a linking requirement for mbedtls.
    (nng.override { mbedtlsSupport = false; })
  ]
  ++ optional (withScripting) wxPython
  ++ optional (withNgspice) libngspice
  ++ optional (debug) valgrind;

  # some ngspice tests attempt to write to $HOME/.cache/
  # this could be and was resolved with XDG_CACHE_HOME = "$TMP";
  # but failing tests still attempt to create $HOME
  # and the newer CLI tests seem to also use $HOME...
  HOME = "$TMP";

  # debug builds fail all but the python test
  doInstallCheck = !(debug);
  installCheckTarget = "test";

  nativeInstallCheckInputs = [
    (python.withPackages (
      ps: with ps; [
        numpy
        pytest
        cairosvg
        pytest-image-diff
      ]
    ))
  ];

  dontStrip = debug;

  meta = {
    description = "Just the built source without the libraries";
    longDescription = ''
      Just the build products, the libraries are passed via an env var in the wrapper, default.nix
    '';
    homepage = "https://www.kicad.org/";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.all;
    broken = stdenv.hostPlatform.isDarwin;
  };
}

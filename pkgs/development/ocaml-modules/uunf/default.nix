{
  lib,
  stdenv,
  fetchurl,
  ocaml,
  findlib,
  ocamlbuild,
  topkg,
  uutf,
  cmdliner,
  cmdlinerSupport ? lib.versionAtLeast cmdliner.version "1.1",
  version ? if lib.versionAtLeast ocaml.version "4.14" then "16.0.0" else "15.0.0",
}:

let
  pname = "uunf";
  webpage = "https://erratique.ch/software/${pname}";
  hash =
    {
      "15.0.0" = "sha256-B/prPAwfqS8ZPS3fyDDIzXWRbKofwOCyCfwvh9veuug=";
      "16.0.0" = "sha256-iQNkT1av6ONJXn3yWbNbEVV8lKGYOKh/nPU0tkUdX64=";
    }
    ."${version}";
in

if lib.versionOlder ocaml.version "4.03" then
  throw "${pname} is not available for OCaml ${ocaml.version}"
else

  stdenv.mkDerivation {
    name = "ocaml${ocaml.version}-${pname}-${version}";
    inherit version;

    src = fetchurl {
      url = "${webpage}/releases/${pname}-${version}.tbz";
      inherit hash;
    };

    nativeBuildInputs = [
      ocaml
      findlib
      ocamlbuild
      topkg
    ];
    buildInputs = [
      topkg
      uutf
    ]
    ++ lib.optional cmdlinerSupport cmdliner;

    strictDeps = true;

    prePatch = lib.optionalString stdenv.hostPlatform.isAarch64 "ulimit -s 16384";

    buildPhase = ''
      runHook preBuild
      ${topkg.run} build \
        --with-uutf true \
        --with-cmdliner ${lib.boolToString cmdlinerSupport}
      runHook postBuild
    '';

    inherit (topkg) installPhase;

    meta = with lib; {
      description = "OCaml module for normalizing Unicode text";
      homepage = webpage;
      license = licenses.bsd3;
      maintainers = [ maintainers.vbgl ];
      mainProgram = "unftrip";
      inherit (ocaml.meta) platforms;
    };
  }

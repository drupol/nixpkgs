{
  lib,
  php,
  fetchFromGitHub,
  versionCheckHook,
  writableTmpDirAsHomeHook,
}:
php.buildComposerProject2 (finalAttrs: {
  pname = "pretty-php";
  version = "0.4.94";

  src = fetchFromGitHub {
    owner = "lkrms";
    repo = "pretty-php";
    tag = "v${finalAttrs.version}";
    hash = "sha256-zBhxuEViLxeQ9m3u1L0wYqeL+YEWWwvJS7PtsFPO5QU=";
  };

  vendorHash = "sha256-IqPDV/1+zwUVusQ51SrzTCOWxz4E949CrtY265DR16c=";

  nativeBuildInputs = [ writableTmpDirAsHomeHook ];
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckKeepEnvironment = [ "HOME" ];
  versionCheckProgramArg = "--version";

  meta = {
    description = "Opinionated PHP code formatter";
    homepage = "https://github.com/lkrms/pretty-php";
    license = lib.licenses.mit;
    mainProgram = "pretty-php";
    maintainers = with lib.maintainers; [ piotrkwiecinski ];
  };
})

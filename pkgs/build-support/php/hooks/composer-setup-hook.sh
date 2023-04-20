if [[ -z "${dontComposerSetupConfigureHook-}" ]]; then
  postConfigureHooks+=(composerSetupConfigureHook)
fi

if [[ -z "${dontComposerSetupBuildHook-}" ]]; then
  preBuildHooks+=(composerSetupBuildHook)
fi

if [[ -z "${dontComposerSetupInstallHook-}" ]]; then
  preInstallHooks+=(composerSetupInstallHook)
fi

composerSetupConfigureHook() {
    echo "Executing composerSetupConfigureHook"

    if [[ ! -d ".composer" ]]; then
        mkdir -p ".composer"
    fi

    if [[ -e "$composerLock" ]]; then
        cp $composerLock composer.lock
    fi

    if [[ ! -f "composer.lock" ]]; then
        echo "No composer.lock file found"
        exit 1
    fi

    echo "Finished composerSetupConfigureHook"
}

composerSetupBuildHook() {
    echo "Executing composerSetupBuildHook"

    argstr="--no-interaction --download-only"
    argstr+=" ${noDevArg}"
    argstr+=" ${noScriptsArg}"
    argstr+=" ${noPluginsArg}"

    COMPOSER_CACHE_DIR=".composer" \
    COMPOSER_HOME=${composerHome} \
    composer install ${argstr}

    echo "Finished composerSetupBuildHook"
}

composerSetupInstallHook() {
    echo "Executing composerSetupInstallHook"

    mkdir -p $out
    cp composer.lock $out/
    cp -ar .composer $out/

    echo "Finished composerSetupInstallHook"
}


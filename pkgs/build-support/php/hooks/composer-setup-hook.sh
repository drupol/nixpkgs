composerSetupConfigureHook() {
    echo "Executing composerSetupConfigureHook"

    if [[ ! -d ".composer" ]]; then
        mkdir -p ".composer"
    fi

    ${lib.optionalString (composerLock != null) "cp ${composerLock} composer.lock"}

    if [[ ! -f "composer.lock" ]]; then
        echo "No composer.lock file found"
        exit 1
    fi

    echo "Finished composerSetupConfigureHook"
}

composerSetupBuildHook() {
    echo "Executing composerSetupBuildHook"

    COMPOSER_CACHE_DIR=".composer" \
    COMPOSER_HOME=${composerHome} \
    composer install \
        ${lib.optionalString (noDev == true) "--no-dev"} \
        ${lib.optionalString (noScripts == true) "--no-scripts"} \
        ${lib.optionalString (noPlugins == true) "--no-plugins"} \
        --download-only

    echo "Finished composerSetupBuildHook"
}

composerSetupInstallHook() {
    echo "Executing composerSetupInstallHook"

    mkdir -p $out
    cp composer.lock $out/
    cp -ar .composer $out/

    echo "Finished composerSetupInstallHook"
}

if [[ -z "${dontComposerSetupConfigureHook-}" ]]; then
  configureHooks+=(composerSetupConfigureHook)
fi

if [[ -z "${dontComposerSetupBuildHook-}" ]]; then
  buildHooks+=(composerSetupBuildHook)
fi

if [[ -z "${dontComposerSetupInstallHook-}" ]]; then
  installHooks+=(composerSetupInstallHook)
fi

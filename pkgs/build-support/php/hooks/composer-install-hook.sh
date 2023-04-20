if [[ -z "${dontComposerInstallConfigureHook-}" ]]; then
  preConfigureHooks+=(composerInstallConfigureHook)
fi

if [[ -z "${dontComposerInstallBuildHook-}" ]]; then
  preBuildHooks+=(composerInstallBuildHook)
fi

if [[ -z "${dontComposerInstallInstallHook-}" ]]; then
  preInstallHooks+=(composerInstallInstallHook)
fi

composerInstallConfigureHook() {
    echo "Executing composerInstallConfigureHook"

    if [[ ! -e "$composerVendor" ]]; then
        echo "No composer cache found."
        exit 1
    fi

    cp -fr $composerVendor/. .
    chmod +w .composer -R

    echo "Finished composerInstallConfigureHook"
}

composerInstallBuildHook() {
    echo "Executing composerInstallBuildHook"

    argstr=("--no-interaction" "--optimize-autoloader")

    if [[ ! -n ${installComposerDevDependencies-} ]]; then
        argstr+=("--no-dev")
    fi

    if [[ ! -n ${installComposerScriptsDependencies-} ]]; then
        argstr+=("--no-scripts")
    fi

    if [[ ! -n ${installComposerPluginsDependencies-} ]]; then
        argstr+=("--no-plugins")
    fi

    argstr+=("${apcuAutoloaderPrefixArg}")

    COMPOSER_DISABLE_NETWORK=1 \
    COMPOSER_CACHE_DIR=.composer \
    composer install ${argstr[@]}

    echo "Finished composerInstallBuildHook"
}

composerInstallInstallHook() {
    echo "Executing composerInstallInstallHook"

    mkdir -p $out/share/php/${pname}
    rm -rf .composer
    cp -r . $out/share/php/${pname}/

    jq -r -c 'try .bin[]' composer.json | while read bin; do
        mkdir -p $out/share/php/${pname} $out/bin
        ln -s $out/share/php/${pname}/$bin $out/bin/$(basename $bin)
    done

    echo "Finished composerInstallInstallHook"
}


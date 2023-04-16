composerInstallConfigureHook() {
    echo "Executing composerInstallConfigureHook"

    if [[ ! -d ".composer" ]]; then
        echo "No composer cache found."
        exit 1
    fi

    cp -fr ${vendor}/* .
    chmod 777 .composer -R

    echo "Finished composerInstallConfigureHook"
}

composerInstallBuildHook() {
    echo "Executing composerInstallBuildHook"

    COMPOSER_DISABLE_NETWORK=1 \
    COMPOSER_CACHE_DIR=.composer \
    composer install \
        --apcu-autoloader-prefix=${prefix} \
        ${lib.optionalString (noDev == true) "--no-dev"} \
        ${lib.optionalString (noScripts == true) "--no-scripts"} \
        ${lib.optionalString (noPlugins == true) "--no-plugins"} \
        --no-interaction \
        --optimize-autoloader

    echo "Finished composerInstallBuildHook"
}

composerInstallInstallHook() {
    echo "Executing composerInstallInstallHook"

    mkdir -p $out/share/php/${finalAttrs.pname} $out/bin
    rm -rf cache
    cp -r . $out/share/php/${finalAttrs.pname}/

    jq -r -c '.bin | .[]' composer.json | while read bin; do
        ln -s $out/share/php/${finalAttrs.pname}/$bin $out/bin/$(basename $bin)
    done

    echo "Finished composerInstallInstallHook"
}

if [[ -z "${dontcomposerInstallConfigureHook-}" ]]; then
  configureHooks+=(composerInstallConfigureHook)
fi

if [[ -z "${dontcomposerInstallBuildHook-}" ]]; then
  buildHooks+=(composerInstallBuildHook)
fi

if [[ -z "${dontcomposerInstallInstallHook-}" ]]; then
  installHooks+=(composerInstallInstallHook)
fi

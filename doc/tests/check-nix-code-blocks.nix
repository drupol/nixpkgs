{
  runCommand,
  markdown-code-runner,
  nixfmt-rfc-style,
}:

runCommand "manual_check-nix-code-blocks"
  {
    nativeBuildInputs = [
      markdown-code-runner
      nixfmt-rfc-style
    ];
  }
  ''
    set +e

    mdcr --check --config ${./mdcr-config.json} ${./..}

    if [ $? -ne 0 ]; then
      echo -e "Error: mdcr command failed. Please make sure the Nix code snippets in Markdown files are correctly formatted.\n"
      echo -e "Run this command from the root path to fix: mdcr --log debug --config doc/tests/mdcr-config.json doc/\n"
      echo -e "\n"
      exit 1
    fi

    touch "$out"
  ''

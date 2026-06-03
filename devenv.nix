{ pkgs, ... }:
let
  nixFiles = "git ls-files '*.nix' -z";
in
{
  packages = with pkgs; [
    commitizen
    deadnix
    git
    nixfmt
    ripsecrets
    statix
    trufflehog
    zizmor
  ];

  scripts = {
    format-nix.exec = ''
      ${nixFiles} | xargs -0 --no-run-if-empty nixfmt
    '';

    check-nix-format.exec = ''
      set -euo pipefail
      ${nixFiles} | xargs -0 --no-run-if-empty nixfmt --check
    '';

    check-nix-lints.exec = ''
      set -euo pipefail
      deadnix --fail .
      statix check .
    '';

    check-secrets.exec = ''
      set -euo pipefail
      ripsecrets .
      trufflehog filesystem . --fail --exclude-paths .trufflehog-exclude
    '';

    check-actions.exec = ''
      set -euo pipefail
      if [ -d .github/workflows ]; then
        zizmor --pedantic .github/workflows
      fi
    '';

    ci-check.exec = ''
      set -euo pipefail
      check-nix-format
      check-nix-lints
      check-secrets
      check-actions
    '';
  };

  git-hooks.hooks = {
    nixfmt.enable = true;
    commitizen.enable = true;
    deadnix.enable = true;
    statix.enable = true;

    ripsecrets.enable = true;
    trufflehog.enable = true;
    "detect-aws-credentials" = {
      enable = true;
      args = [ "--allow-missing-credentials" ];
    };
    "detect-private-keys".enable = true;

    zizmor.enable = true;
  };
}

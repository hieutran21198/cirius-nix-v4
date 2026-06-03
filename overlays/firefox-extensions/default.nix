{ inputs, ... }:
_: prev: {
  firefox-extensions = inputs.firefox-addons.packages.${prev.stdenv.hostPlatform.system};
}

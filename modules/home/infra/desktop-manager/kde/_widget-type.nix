{
  lib,
  namespace,
  ...
}:
let
  inherit (lib.${namespace}) makeAttrsOption;
in
lib.types.submodule (
  { config, name, ... }: {
    options = {
      topLevelConfig = makeAttrsOption {
        ofType = lib.types.anything;
        nullable = true;
        description = "Top-level configuration for the widget. (Plasma Manager Widget)";
      };
      config = makeAttrsOption {
        ofType = lib.types.anything;
        nullable = true;
        description = "Configuration for the widget.";
      };
      built = {
        widget = makeAttrsOption {
          ofType = lib.types.anything;
          readOnly = true;
          description = "The built widget object.";
        };
      };
    };

    config = {
      assertions = [
        {
          assertion = config.id != "";
          message = "The ID of the widget must be set.";
        }
        {
          assertions = name != "";
          message = "The name of the widget must be set.";
        }
        {
          assertion = config.config != null || config.topLevelConfig != null;
          message = "Either config or topLevelConfig must be set for the widget.";
        }
      ];

      built.widget = {
        inherit name;
      }
      // (lib.optionalAttrs (config.topLevelConfig != null) config.topLevelConfig)
      // (lib.optionalAttrs (config.config != null) { inherit (config) config; });
    };
  }
)

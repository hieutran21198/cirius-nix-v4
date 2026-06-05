{
  lib,
  ...
}:
let

  makePrimitiveType =
    primitiveType:
    {
      description ? "",
      readOnly ? false,
      nullable ? false,
      default ? null,
      ...
    }:
    lib.mkOption (
      {
        inherit readOnly;
        type = with lib.types; if nullable then (nullOr primitiveType) else primitiveType;
        description = if description != "" then description else "Value to be set";
      }
      // (lib.optionalAttrs (default != null || nullable) {
        inherit default;
      })
    );

in
{
  inherit makePrimitiveType;
  makePackageOption = inputs: makePrimitiveType lib.types.package inputs;
  makeStrOption = inputs: makePrimitiveType lib.types.str inputs;
  makeIntOption = inputs: makePrimitiveType lib.types.int inputs;
  makeFloatOption = inputs: makePrimitiveType lib.types.float inputs;
  makeBoolOption = inputs: makePrimitiveType lib.types.bool inputs;
  makeEnumOption =
    {
      acceptedList ? [ ],
      ...
    }@inputs:
    makePrimitiveType (lib.types.enum acceptedList) inputs;
  makeListOption =
    {
      ofType ? lib.types.anything,
      ...
    }@inputs:
    makePrimitiveType (lib.types.listOf ofType) inputs;
  makeAttrsOption =
    {
      ofType ? lib.types.anything,
      ...
    }@inputs:
    makePrimitiveType (lib.types.attrsOf ofType) inputs;

  failWhen =
    { condition, message, ... }:
    {
      assertion = condition == false;
      inherit message;
    };
}

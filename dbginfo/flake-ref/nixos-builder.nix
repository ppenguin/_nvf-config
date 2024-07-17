{ inputs, ... }:
let

  inherit (inputs.nixpkgs) lib;

  mkSysConfig = system: modules:
    if (lib.hasInfix "darwin" system) then
      inputs.darwin.lib.darwinSystem
        {
          inherit system modules;
          specialArgs = { };
        }
    else
      inputs.nixpkgs.lib.nixosSystem {
        inherit system modules;
        specialArgs = {
          inherit inputs system;
        };
      };

  # _getUsers returns a list of import paths containing user definitions
  _getUsers = users:
    map (u: ./. + "/users/${u}.nix") users # user expressions referred by list
    ++ [ (./. + "/users") ]; # add default

  # _getHostConfig reads cfgfile (`hosts/<host>/default.nix`) and returns a nixosSystem from the definitions in it
  _getHostConfig = host:
    let
      hostdef = import (./. + "/hosts/${host}") { inherit inputs; }; # this will return the attributes (for now { system modules users }) from the default host config
      system = hostdef.system;
      allmodules = [
        inputs.nurpkgs.nixosModules.nur
        ./overlays # now as a normal module, that also handles unstable and adding the _module.arg.unstable
      ]
      ++ hostdef.modules ++ _getUsers hostdef.users
      ++ lib.optionals (! lib.hasInfix "darwin" system) [
        # disko needs boot attr. and sops on system level systemd
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
      ];
    in
    mkSysConfig system allmodules;

  _getAllHostConfigs = machinedir:
    lib.mapAttrs (n: _: (_getHostConfig n))
      (lib.filterAttrs (_: v: v == "directory") (builtins.readDir machinedir));

in
{
  /*** `getNixosConfigs` should return a valid `nixosConfigurations` attribute set, i.e. as returned by `lib.nixosSystem`
    {
      hostname = lib.nixosSystem {
        inherit system modules;
        specialArgs = { ... }
      }
      ...
      host-x = { ... }
    }

    where `modules` is basically just the `imports = [ configuration.nix ... ]` list.
    That means that any logic to "choose" imports based on known values at this point (hostname, system, definitions in `hosts/<host>/default.nix`)
    can/should be handled here in functions just returning the conditionally determined relevant imports paths which is then passed as the `modules` parameter.
    The same for `users` (also defined in `hosts/<host>/default.nix`)
  */
  getNixosConfigs = machinedir:
    lib.filterAttrs (_: v: ! lib.hasInfix "darwin" (lib.getAttrFromPath [ "pkgs" "system" ] v))
      (_getAllHostConfigs machinedir);

  getDarwinConfigs = machinedir:
    lib.filterAttrs (_: v: lib.hasInfix "darwin" (lib.getAttrFromPath [ "pkgs" "system" ] v))
      (_getAllHostConfigs machinedir);
}

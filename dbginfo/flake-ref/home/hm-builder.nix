{ inputs, systemConfigs, lib, ... }:

# Since, by definition, users run *on* a system, we will take the realised system config
# and its current config and packages state as input for  the HM config(s).
# This is even one "better" than using channels in terms of duplication, since it will
# use a common state for pkgs and unstable.

let
  mkHome = username: hostname:
    (
      let
        inherit (systemConfigs."${hostname}") pkgs config;
        inherit (systemConfigs."${hostname}"._module.args) nur nixpkgs-master std;
        inherit (pkgs) system;
        osConfig = config;
        homeDirectory = "${
          if lib.hasInfix "darwin" system then "/Users" else "/home"
        }/${username}";
        # configHome = "${homeDirectory}/.config";
      in
      inputs.home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ../home/home.nix
          "${inputs.sops-nix}/modules/home-manager/sops.nix"
          (if builtins.pathExists (./. + "/${username}/overlays") then
            (./. + "/${username}/overlays")
          else
            { })
        ];
        extraSpecialArgs = {
          inherit inputs username std nur nixpkgs-master hostname homeDirectory osConfig;
        };
      }
    );
in
{
  /* getHMConfigs returns all <user>@<host> = <HMConfig> attributes according to the user lists in all machine configs
     That means: mkHome for each username@hostname that satisfies the following conditions
     - has a dir in ./home
     - occurs in <hostname>.config.users.users && isNormalUser in that set
     needs some hocus pocus to restructure ...
  */
  getHMConfigs =
    let
      hmusers = lib.attrsets.attrNames
        (lib.filterAttrs (n: v: v == "directory") (builtins.readDir ./.));
      # hostusers doesn't work well on darwin if you rely on non-nix managed users
      # so we probably need to just get the users from hostdef on darwin
      hostusers = builtins.mapAttrs (n: v: v.config.users.users) systemConfigs;
    in
    lib.attrsets.zipAttrsWith (n: v: builtins.elemAt v 0)
      (builtins.filter (i: i != { }) (lib.lists.flatten (map
        (cfghost:
          map
            (hmusr:
              if (builtins.hasAttr hmusr (builtins.getAttr cfghost hostusers)) then {
                "${hmusr}@${cfghost}" = (mkHome hmusr cfghost);
              } else
                { })
            hmusers)
        (builtins.attrNames hostusers))));
}

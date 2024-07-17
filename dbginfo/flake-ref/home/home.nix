{ pkgs, username, homeDirectory # ? pkgs.config.homeDirectory
, hostname, osConfig, lib ? pkgs.lib, ... }:

{
  imports = [
    ./switch.nix # put the switch script (to apply this flake for system and HM config) in the user's ${HOME}/.local/bin
    (./.
      + "/${username}/${hostname}") # much simplified: just enforce that the user@host has indeed a defined default.nix in place
  ];

  # home.packages = [ pkgs.home-manager ];
  programs.home-manager.enable = true;

  home.sessionPath = [ "${homeDirectory}/bin" ]
    ++ (if osConfig ? "homebrew" then
      lib.optionals osConfig.homebrew.enable [ "/opt/homebrew/bin" ]
    else
      [ ]); # add to PATH
  fonts.fontconfig.enable = true;
  home.username = username;
  home.homeDirectory = homeDirectory;
  home.stateVersion = "23.11";
}

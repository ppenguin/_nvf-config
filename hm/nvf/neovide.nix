{
  inputs,
  config,
  pkgs,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
in {
  home.packages = with pkgs; [
    (writeShellScriptBin "nv" ''
      if [ -z ''${DISPLAY+x} ] && [ -z ''${WAYLAND_DISPLAY+x} ]; then
        nvim $@ # must be in the path, we don't want unwrapped because it's not nixvim configged
      else
        ${neovide}/bin/neovide --fork --grid -- $@
      fi
    '')
  ];

  # extra luaConfig (entryAnywhere is necessary for nixos module merging behaviour)
  programs.nvf.settings.vim.luaConfigRC.neovide = entryAnywhere ''
    -- settings for neovide
    if vim.g.neovide then
      vim.o.guifont = "${
      builtins.replaceStrings [" "] ["_"]
      config.stylix.fonts.monospace.name
    }:h14"

      vim.g.neovide_cursor_vfx_mode = "torpedo"
    end
  '';
}

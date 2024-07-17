# TODO:
{pkgs, ...}: {
  programs.nvf.settings.vim = {
    # This becomes possible after activating the upstream "attr merge fix":
    # optPlugins = with pkgs.vimPlugins;
    #   lib.mkMerge [
    #     plenary-nvim
    #     neotest-plenary
    #     neotest-go
    #     neotest-python
    #   ];

    extraPlugins = with pkgs.vimPlugins; {
      neotest = {
        package = neotest;
        setup = ''
          require("neotest").setup({
            adapters = {
              require("neotest-python")({
                dap = { justMyCode = false },
              }),
              require("neotest-go")({
                dap = { justMyCode = false },
              }),
              require("neotest-plenary"),
            },
          })
        '';
      };
      # neotest-go = {package = neotest-go;};
      # neotest-python = {package = neotest-python;};
    };
  };
}

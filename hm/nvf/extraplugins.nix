{
  lib,
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.binds) mkBinding;
in {
  programs.nvf.settings.vim = {
    luaPackages = [
      # for nvim-rest
      "mimetypes"
      "lua-curl"
      "xml2lua"
      "nvim-nio"
    ];
    # mkMerge basically does the same in this context as some hocus pocus with mapAttrs or nameValuePair,
    # so we can have a list of function results for mkBinding
    maps.normal = lib.mkMerge [
      (mkBinding "<leader>aa" "<CMD>AerialToggle!<CR>" "Toggle Aerial")
      (mkBinding "<leader>rq" ''<CMD>lua require("rest-nvim").run()<CR>'' "Rest: run request")
      (mkBinding "<leader>rl" ''<CMD>lua require("rest-nvim").last()<CR>'' "Rest: last request")
    ];

    # put here if no custom setup is necessary
    optPlugins = with pkgs.vimPlugins; [
      indent-blankline-nvim
      rainbow-delimiters-nvim
      rest-nvim
      trouble-nvim
      vim-flog
      vim-fugitive # TODO: check out fugitive-gitlab-vim
      # for neotest
      plenary-nvim
      # neotest-vim-test
      neotest-plenary
      neotest-go
      neotest-python
    ];

    # here we can provide custom setup
    extraPlugins = with pkgs.vimPlugins; {
      aerial = {
        package = aerial-nvim;
        setup = ''
          require("aerial").setup({
            on_attach = function(bufnr)
              vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
              vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
            end,
          })
        '';
      };
    };
  };
}

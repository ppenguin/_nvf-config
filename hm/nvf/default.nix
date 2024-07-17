{
  inputs,
  pkgs,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.dag) entryAnywhere;
  inherit (inputs.nvf.lib.nvim.binds) mkBinding;
in {
  imports = [
    inputs.nvf.homeManagerModules.default
    ./extraplugins.nix
    ./bindsglobal.nix
    ./neovide.nix
    # ./neotest.nix
  ];

  home.packages = with pkgs; [
    wl-clipboard
  ];

  programs.nvf = {
    enable = true;
    settings = {
      vim = {
        theme = {
          enable = true;
          name = "tokyonight";
          style = "night";
        };
        mapLeaderSpace = false; # then the default is \
        vimAlias = true; # now switched off in nixvim

        enableLuaLoader = true;

        enableEditorconfig = true;

        extraPackages = with pkgs; [
          fzf
          ripgrep
        ];

        # some basic features
        autocomplete = {enable = true;};

        autopairs.enable = true;

        binds = {
          cheatsheet.enable = true;
          whichKey.enable = true;
        };

        dashboard.startify.enable = true;

        statusline.lualine = {
          enable = true;
          activeSection.b = [(builtins.readFile ./lua-include/lualine.b.lua)];
        };

        telescope = {
          enable = true;
        };

        filetree.nvimTree = {
          enable = true;
          mappings.toggle = "<C-/>";
          setupOpts = {
            git.enable = true;
            # hijack_unnamed_buffer_when_opening = true;
            modified.enable = true;
            renderer = {
              add_trailing = true;
              highlight_git = true;
              highlight_modified = "name";
              highlight_opened_files = "icon";
            };
            update_focused_file.enable = true;
            # view.float.enable = true;
          };
        };

        notes = {
          todo-comments = {enable = true;};
        };

        utility = {
          preview.markdownPreview = {
            enable = true;
            autoStart = false;
            lazyRefresh = true;
          };
          surround = {
            enable = true;
          };
          motion = {
            hop.enable = true;
            leap.enable = true;
          };
        };

        git = {
          enable = true;
          gitsigns.enable = true;
        };

        terminal.toggleterm = {
          enable = true;
          mappings.open = "<leader>,";
          setupOpts.direction = "float";
          lazygit = {
            enable = true;
            # mappings.open = "<leader>zg"; # default: \gg
          };
        };

        maps.terminal."<leader>," = {
          # lua = true;
          # action = ''require('toggleterm').toggle()'';
          action = "<CMD>ToggleTermToggleAll!<CR>";
          desc = "Close/hide toggleterm (without exiting the process)";
          silent = true;
        };

        comments.comment-nvim.enable = true; # has good defaults?

        # builtin language support
        lsp = {
          enable = true;
          formatOnSave = true;
          lightbulb.enable = true;
          nvimCodeActionMenu.enable = true;
          trouble.enable = true;
          lspSignature.enable = true;
        };

        languages =
          {
            enableLSP = true;
            enableFormat = true;
            enableTreesitter = true;
          }
          // builtins.listToAttrs (
            map (key: {
              name = key;
              value = {enable = true;};
            })
            ["nix" "sql" "ts" "go" "python" "html" "lua" "dart" "markdown" "clang" "rust" "zig" "bash" "css" "svelte" "terraform"]
          )
          // {
            # tweak (override) defaults for specific languages
            markdown = {
              format.enable = false;
            };
          };

        # extra luaConfig (entryAnywhere is necessary for nixos module merging behaviour)
        # some hocus pocus to get a border for lsp stuff from
        #   https://github.com/jdhao/nvim-config/blob/master/lua/config/lsp.lua#L177-L179
        # TODO: does this have overlap with some defaults?!
        # FIXME: actually the official instruction is here:
        #   https://github.com/neovim/nvim-lspconfig/wiki/UI-Customization
        luaConfigRC.lsp-opts = entryAnywhere ''
          -- "fix" lsp popup (add border)
          local border = "single";
          local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
          function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
            opts = opts or {}
            opts.border = opts.border or border
            return orig_util_open_floating_preview(contents, syntax, opts, ...)
          end
        '';
      };
    };
  };
}

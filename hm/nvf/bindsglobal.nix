{
  lib,
  inputs,
  ...
}: let
  inherit (inputs.nvf.lib.nvim.binds) mkBinding;
in {
  # mkMerge basically does the same in this context as some hocus pocus with mapAttrs or nameValuePair,
  # so we can have a list of function results for mkBinding
  programs.nvf.settings.vim.maps = {
    normal = lib.mkMerge [
      # ergonomic motions
      (mkBinding "<M-Right>" "<C-w>l" "Go to right pane")
      (mkBinding "<M-S-Right>" "<C-w>10<char-62>" "Pane 10c wider")
      (mkBinding "<M-Left>" "<C-w>h" "go left pane")
      (mkBinding "<M-S-Left>" "<C-w>10<lt>" "Pane 10c narrower")
      (mkBinding "<M-Up>" "<C-w>k" "go up pane")
      (mkBinding "<M-S-Up>" "<C-w>5+" "Pane 5l taller")
      (mkBinding "<M-Down>" "<C-w>j" "go down pane")
      (mkBinding "<M-S-Down>" "<C-w>5-" "Pane 5l shorter")
      (mkBinding "<C-x>" "<CMD>bd<CR>" "Close current buffer")
      # custom rendering (e.g. pandoc)
      (mkBinding "<leader>mp" "<CMD>!md2pdf %<CR>" "make pdf with pandocomatic")
      (mkBinding "<leader>mpo" "<CMD>!md2pdf --open %<CR>" "make pdf with pandocomatic and open in PDF viewer")
      # reload config
      (mkBinding "<leader>rc" "<CMD>source $MYVIMRC<CR>" "reload config")
      # handy
      (mkBinding "<leader>x" ''"_x'' "delete character without copy")
      (mkBinding "<leader>d" ''"_d'' "delete <motion> without copy")
      (mkBinding "<leader>dd" ''"_dd'' "delete line without copy")
      (mkBinding "<leader>:" "<CMD>Telescope commands<CR>" "Telescope commands")
      # copy/paste with clipboard
      (mkBinding "<leader>yy" ''"+yy'' "Yank line to system clipboard")
      (mkBinding "<leader>y" ''"+y'' "Yank <motion> to system clipboard")
      (mkBinding "<leader>p" ''"+p'' "Paste-after from system clipboard")
      (mkBinding "<leader>P" ''"+P'' "Paste-at from system clipboard")
    ];

    visual = lib.mkMerge [
      (mkBinding "<leader>y" ''"+y'' "Yank selection to system clipboard")
      (mkBinding "<leader>d" ''"_d'' "delete selection without copy")
      # json utils
      (mkBinding "<leader>js" "<CMD>!jq --sort-keys<CR>" "Sort json by keys")
      (mkBinding "<leader>je" ''<CMD>!jq 'reduce to_entries[] as $kv ({}; setpath($kv.key|split("."); $kv.value))'<CR>'' "Expand json keys")
    ];
  };
}

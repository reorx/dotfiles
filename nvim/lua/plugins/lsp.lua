return {
  { 'neovim/nvim-lspconfig' },
  -- TODO { 'do': ':MasonUpdate' }
  { 'mason-org/mason.nvim' },
  {
    "mason-org/mason-lspconfig.nvim",
    --opts = {},
    --dependencies = {
    --  { "mason-org/mason.nvim", opts = {} },
    --  "neovim/nvim-lspconfig",
    --},
  },
  -- 🐼
  { 'ray-x/lsp_signature.nvim' },
  -- lsp_lines: renders diagnostics using virtual lines on top of the real line of code.
  -- { 'https://git.sr.ht/~whynothugo/lsp_lines.nvim' },
  { 'rmagatti/goto-preview' },
  { 'hrsh7th/cmp-nvim-lsp-signature-help' },
}

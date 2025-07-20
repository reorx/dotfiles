return {
  {
    "yetone/avante.nvim",
    enabled = true,
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    -- ⚠️ must add this setting! ! !
    build = function()
      return "make"
    end,
    version = false, -- Never set this value to "*"! Never!
    keys = {
      { "<leader>c", "<cmd>AvanteToggle<cr>", desc = "LLM chat" },
    },
    ---@module 'avante'
    ---@type avante.Config
    opts = {
      -- add any opts here
      -- for example
      provider = "claude",
      providers = {
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-sonnet-4-20250514",
          timeout = 30000, -- Timeout in milliseconds
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 20480,
          },
        },
      },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
  },
  {
    'github/copilot.vim',
    enabled = false,
    cmd = 'Copilot',
  },
}

return {
  -- Disable animations to eliminate CPU wakeups and save memory
  {
    "folke/snacks.nvim",
    opts = {
      animate = { enabled = false },
      scroll = { enabled = false }, -- instant scrolling without render overhead
    },
  },

  -- Lightweight treesitter configuration
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      highlight = { enable = true },
      indent = { enable = false }, -- tree-sitter indent can be slow on large files
    },
  },

  -- Minimalist indent guides (disable animated scopes)
  {
    "lukas-reineke/indent-blankline.nvim",
    opts = {
      scope = { enabled = false },
    },
  },
}

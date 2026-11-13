return {
  {
    "HakonHarnes/img-clip.nvim",
    ft = { "markdown" },
    cmd = "PasteImage",
    opts = {
      default = {
        dir_path = "assets",
        relative_to_current_file = true,
        copy_images = true,
        prompt_for_file_name = false,
      },
    },
    keys = {
      { "<leader>mi", "<cmd>PasteImage<cr>", ft = "markdown", desc = "Paste image into document" },
    },
  },
  {
    "bullets-vim/bullets.vim",
    ft = { "markdown" },
    init = function()
      vim.g.bullets_enabled_file_types = { "markdown" }
      vim.g.bullets_checkbox_markers = " x"
      vim.g.bullets_set_mappings = 0
      vim.g.bullets_enable_in_empty_buffers = 0
      vim.g.bullets_custom_mappings = {
        { "imap", "<CR>", "<Plug>(bullets-newline)" },
        { "nmap", "o", "<Plug>(bullets-newline)" },
        { "nmap", "gN", "<Plug>(bullets-renumber)" },
        { "nmap", "<leader>mc", "<Plug>(bullets-toggle-checkbox)" },
        { "imap", "<C-t>", "<Plug>(bullets-demote)" },
        { "imap", "<C-d>", "<Plug>(bullets-promote)" },
      }
    end,
  },
  {
    "dhruvasagar/vim-table-mode",
    ft = { "markdown" },
    init = function()
      vim.g.table_mode_disable_mappings = 1
      vim.g.table_mode_corner = "|"
    end,
    keys = {
      { "<leader>mt", "<cmd>TableModeToggle<cr>", ft = "markdown", desc = "Toggle Markdown table alignment" },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        prettier = { prepend_args = { "--prose-wrap", "preserve" } },
      },
    },
  },
}

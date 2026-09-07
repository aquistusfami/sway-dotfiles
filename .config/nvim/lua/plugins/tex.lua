return {
  -- VimTeX: The definitive LaTeX plugin for Neovim
  {
    "lervag/vimtex",
    lazy = false, -- Recommended by VimTeX maintainers for proper ftplugin initialization
    init = function()
      -- PDF Viewer: Zathura with SyncTeX
      vim.g.vimtex_view_method = "zathura"

      -- Compiler: Modern Tectonic Engine
      vim.g.vimtex_compiler_method = "tectonic"
      vim.g.vimtex_compiler_tectonic = {
        options = {
          "--synctex",
          "--keep-logs",
          "--keep-intermediates",
        },
      }

      -- Clean ergonomics: Don't pop up quickfix for minor warnings
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_syntax_enabled = 1
      vim.g.vimtex_toc_config = {
        name = "Table of Contents",
        split_width = 30,
        mode = 2,
      }
    end,
  },
}

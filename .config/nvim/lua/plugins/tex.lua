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

      -- Tự động sinh \end{...} khi gõ xong \begin{...} và bấm Enter
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "tex", "latex", "plaintex" },
        callback = function(ev)
          vim.keymap.set("i", "<CR>", function()
            local line = vim.api.nvim_get_current_line()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local before = line:sub(1, col)
            local after = line:sub(col + 1)
            local env = before:match("\\begin%{([%a%*@_]+)%}%s*$")
            if not env and after:match("^%}") then
              env = before:match("\\begin%{([%a%*@_]+)$")
            end
            if env then
              local current_row = vim.api.nvim_win_get_cursor(0)[1]
              local indent = line:match("^(%s*)") or ""
              local tab = "  "
              local cur_line = indent .. "\\begin{" .. env .. "}"
              vim.api.nvim_buf_set_lines(0, current_row - 1, current_row, false, {
                cur_line,
                indent .. tab,
                indent .. "\\end{" .. env .. "}",
              })
              vim.api.nvim_win_set_cursor(0, { current_row + 1, #indent + #tab })
              return ""
            end
            return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
          end, { buffer = ev.buf, expr = true, desc = "Auto-close LaTeX environment" })
        end,
      })
    end,
  },
}

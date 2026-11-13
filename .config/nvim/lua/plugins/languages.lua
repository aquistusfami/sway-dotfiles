return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters = {
        csharpier = {
          env = { DOTNET_ROOT = vim.fn.expand("~/.local/share/dotnet") },
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = { fsautocomplete = { enabled = false } },
    },
  },
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      -- C# support uses the .NET extra; skip its unused F# formatter.
      opts.ensure_installed = vim.tbl_filter(function(name)
        return name ~= "fantomas"
      end, opts.ensure_installed or {})
      vim.list_extend(opts.ensure_installed, { "rust-analyzer" })
    end,
  },
}

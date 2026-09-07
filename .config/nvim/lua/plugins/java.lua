return {
  -- Configure nvim-jdtls for RAM efficiency and OOP ergonomics
  {
    "mfussenegger/nvim-jdtls",
    opts = function(_, opts)
      opts.cmd = opts.cmd or { vim.fn.exepath("jdtls") }

      -- Cap JDTLS heap at 512MB to strictly optimize RAM on 8GB systems
      table.insert(opts.cmd, "--jvm-arg=-Xms64m")
      table.insert(opts.cmd, "--jvm-arg=-Xmx512m")
      table.insert(opts.cmd, "--jvm-arg=-XX:+UseG1GC")
      table.insert(opts.cmd, "--jvm-arg=-XX:+UseStringDeduplication")

      opts.settings = vim.tbl_deep_extend("force", opts.settings or {}, {
        java = {
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" },
          completion = {
            favoriteStaticMembers = {
              "org.junit.Assert.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
            },
            filteredTypes = {
              "com.sun.*",
              "sun.*",
              "jdk.*",
            },
          },
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            hashCodeEquals = {
              useJava7Objects = true,
            },
            useBlocks = true,
          },
        },
      })
      return opts
    end,
  },
}

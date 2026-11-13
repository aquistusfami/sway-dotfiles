-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Chỉ tài liệu dùng ngắt dòng mềm; code giữ dòng gốc.
vim.opt.wrap = false -- Tài liệu bật wrap riêng qua FileType.
vim.opt.linebreak = true -- Ngắt dòng theo từ ngữ, không cắt đôi từ/công thức
vim.opt.breakindent = true -- Giữ thụt lề thẳng hàng khi dòng bị ngắt
vim.opt.showbreak = "↳ " -- Ký hiệu hiển thị ở đầu dòng được ngắt

-- Use the installed rustup toolchain for Cargo, rustfmt and Rust language tools.
vim.env.PATH = vim.fn.expand("~/.cargo/bin") .. ":" .. vim.env.PATH

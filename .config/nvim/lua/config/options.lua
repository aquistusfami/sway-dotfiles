-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Tự động ngắt dòng mềm theo khung cửa sổ (Word Wrap)
vim.opt.wrap = true -- Giới hạn dòng hiển thị theo khung cửa sổ (không tràn vô cực)
vim.opt.linebreak = true -- Ngắt dòng theo từ ngữ, không cắt đôi từ/công thức
vim.opt.breakindent = true -- Giữ thụt lề thẳng hàng khi dòng bị ngắt
vim.opt.showbreak = "↳ " -- Ký hiệu hiển thị ở đầu dòng được ngắt

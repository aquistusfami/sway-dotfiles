local map = vim.keymap.set

-- Quick Save & Quit
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save File" })
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

-- Ctrl+S: Lưu file & Tự động biên dịch (nếu là file LaTeX)
local function save_and_compile()
  vim.cmd("silent! write")
  if vim.bo.filetype == "tex" then
    local is_running = (vim.fn.exists("*vimtex#compiler#is_running") == 1)
      and (vim.fn["vimtex#compiler#is_running"]() == 1)
    if is_running then
      vim.notify("Đã lưu & đang cập nhật PDF...", vim.log.levels.INFO, { title = "VimTeX" })
    else
      vim.cmd("silent! VimtexCompileSS")
      vim.notify("Đã lưu & biên dịch PDF!", vim.log.levels.INFO, { title = "VimTeX" })
    end
  end
end

map({ "i", "x", "n", "s" }, "<C-s>", function()
  save_and_compile()
  vim.cmd("stopinsert")
end, { desc = "Save File & Compile (LaTeX)" })

-- Fast Java Single-file / Project Runner (<leader>rr)
map("n", "<leader>rr", function()
  vim.cmd("write")
  local file = vim.fn.expand("%:p")
  local ext = vim.fn.expand("%:e")
  if ext == "java" then
    local dir = vim.fn.expand("%:p:h")
    local filename = vim.fn.expand("%:t:r")
    local pom = vim.fs.find("pom.xml", { upward = true, path = dir })[1]
    local gradle = vim.fs.find("build.gradle", { upward = true, path = dir })[1]
    local cmd
    if pom then
      local root = vim.fs.dirname(pom)
      cmd = string.format("cd %s && mvn compile exec:java", vim.fn.shellescape(root))
    elseif gradle then
      local root = vim.fs.dirname(gradle)
      cmd = string.format("cd %s && ./gradlew run", vim.fn.shellescape(root))
    else
      cmd = string.format("cd %s && javac *.java && java %s", vim.fn.shellescape(dir), filename)
    end
    if Snacks and Snacks.terminal then
      Snacks.terminal(cmd, { interactive = true })
    else
      vim.cmd("split | terminal " .. cmd)
    end
  else
    vim.notify("Not a Java file!", vim.log.levels.WARN)
  end
end, { desc = "Run Java File / Project" })

-- Java OOP Shortcuts
vim.api.nvim_create_autocmd("FileType", {
  pattern = "java",
  callback = function()
    local ok, jdtls = pcall(require, "jdtls")
    if ok then
      map("n", "<leader>co", jdtls.organize_imports, { buffer = true, desc = "Organize Imports" })
      map("n", "<leader>ce", jdtls.extract_variable, { buffer = true, desc = "Extract Variable" })
      map("n", "<leader>cc", jdtls.extract_constant, { buffer = true, desc = "Extract Constant" })
      map("v", "<leader>cm", function() jdtls.extract_method(true) end, { buffer = true, desc = "Extract Method" })
    end
    map("n", "<leader>ca", vim.lsp.buf.code_action, { buffer = true, desc = "Java Code Action / Generate" })
  end,
})

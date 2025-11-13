-- ============================================================================
-- Windows-Specific Configuration
-- ============================================================================

-- PowerShell as default shell on Windows
vim.opt.shell = "powershell.exe"
vim.opt.shellxquote = ""
vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
vim.opt.shellquote = ""
vim.opt.shellpipe = "| Out-File -Encoding UTF8 %s"
vim.opt.shellredir = "| Out-File -Encoding UTF8 %s"

print("Windows-specific settings loaded")

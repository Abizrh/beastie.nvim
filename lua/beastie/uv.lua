local uv
-- Doing so we support older versions of neovim
if vim.uv then
  uv = vim.uv
else
  uv = vim.loop
end

return uv

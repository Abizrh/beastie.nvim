--- UI module
local UI = {}

---@param initial_frame string
function UI.create_buffer_ui(initial_frame)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, { initial_frame })

  local opts = {
    relative = 'editor',
    width = 2,
    height = 1,
    row = 5,
    col = 5,
    style = 'minimal'
  }

  local win = vim.api.nvim_open_win(buf, false, opts)
  return buf, win, opts
end

---@param buf number
---@param win number
---@param opts table
---@param new_frame string
function UI.update_beastie(buf, win, opts, new_frame)
  if vim.api.nvim_buf_is_valid(buf) and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { new_frame })
    vim.api.nvim_win_set_config(win, opts)
  end
end

return UI

--- UI module
local UI = {}

UI.cage_buf, UI.cage_win, UI.cage_bounds = nil, nil, nil

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
    style = 'minimal',
    zindex = 150,
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

-- TODO: create buffer ui for beastie cage
function UI.create_buffer_cage_ui()
  local buf = vim.api.nvim_create_buf(false, true)
  local win_width = vim.api.nvim_win_get_width(0)
  local right_col = win_width - 37
  local cage_width = 37
  local cage_height = 50
  local cage_row = 10
  local cage_col = right_col

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    " ================================== ",
    " ",
    " ▗▄▄▖ ▗▄▄▄▖ ▗▄▖  ▗▄▄▖▗▄▄▄▖▗▄▄▄▖▗▄▄▄▖",
    " ▐▌ ▐▌▐▌   ▐▌ ▐▌▐▌     █    █  ▐▌   ",
    " ▐▛▀▚▖▐▛▀▀▘▐▛▀▜▌ ▝▀▚▖  █    █  ▐▛▀▀ ",
    " ▐▙▄▞▘▐▙▄▄▖▐▌ ▐▌▗▄▄▞▘  █  ▗▄█▄▖▐▙▄▄ ",
    " ",
    "                             v2.0.0 ",
    " ================================== ",
  })
  local win = vim.api.nvim_open_win(buf, true, {
    relative = 'win',
    width = cage_width,
    height = cage_height,
    row = cage_row,
    col = cage_col,
    border = 'double',
    style = 'minimal'
  })

  UI.cage_buf = buf
  UI.cage_win = win
  UI.cage_bounds = {
    row_min = cage_row + 4,
    row_max = cage_row + cage_height - 6,
    col_min = cage_col + 4,
    col_max = cage_col + cage_width - 9,
  }
end

return UI

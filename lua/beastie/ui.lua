local config = require('beastie.config')
-- @return table
local function createBufferOpts()
  local opts = {
    relative = 'editor',
    width = 3,
    height = 1,
    row = 5,
    col = 5,
    style = 'minimal'
  }
  return opts
end

local function createBufferUi()
  local buffer = vim.api.nvim_create_buf(false, true)
  -- apply_buffer_keymaps(buffer)
  return buffer
end


---@class BeastieUI
---@field buffer integer
---@field buffer_opts table
local UI = {}
UI.buffer = createBufferUi()
UI.buffer_opts = createBufferOpts()

---@param beastie Beastie
function UI.updateUI(beastie)
  UI.buffer_opts.col = UI.buffer_opts.col + 1
  if UI.buffer_opts.col > vim.o.columns - 5 then
    UI.buffer_opts.col = 5
  end

  vim.api.nvim_buf_set_lines(UI.buffer, 0, -1, false, { config.options.frames[beastie.frame_index] })
  vim.api.nvim_open_win(UI.buffer, false, UI.buffer_opts)
end

return UI

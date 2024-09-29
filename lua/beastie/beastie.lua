local ui = require('beastie.ui')
local config = require('beastie.config')


---@class Beastie
---@field current_frame string
---@field frame_index integer
---@field frames table
---@field animation_speed integer
---@field start_at_launch boolean
local beastie = {}

beastie.current_frame = nil
beastie.frame_index = 1


function beastie.update_frame()
  beastie.frame_index = beastie.frame_index + 1
  if beastie.frame_index > #config.options.frames then
    beastie.frame_index = 1
  end
  beastie.current_frame = config.options.frames[beastie.frame_index]
end

function beastie.start_beastie()
  beastie.current_frame = config.options.frames[beastie.frame_index]
  beastie.timer = vim.loop.new_timer()
  beastie.timer:start(0, config.options.animation_speed, vim.schedule_wrap(function()
    beastie.update_frame()
    ui.updateUI(beastie)
  end))
end

function beastie.stop_beastie()
  if beastie.timer then
    beastie.timer:stop()
    beastie.timer:close()
    beastie.timer = nil
  end
end

---@class BeastieOpts
---@field frames table
---@field animation_speed integer
---@field start_at_launch boolean

---@param opts BeastieOpts
function beastie.setup(opts)
  config.setup(opts)

  vim.api.nvim_create_user_command('StartBeastie', beastie.start_beastie, {})
  vim.api.nvim_create_user_command('StopBeastie', beastie.stop_beastie, {})

  if beastie.start_at_launch then
    beastie.start_beastie()
  end
end

return beastie

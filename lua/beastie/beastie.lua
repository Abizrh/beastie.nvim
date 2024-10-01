local ui = require('beastie.ui')
local log = require('beastie.log')
local uv = require('beastie.uv')

local beastie = {}
local config, frame_idx, buf, win, window_opts, timer

---@class BeastieSet
---@field frames string[]
---@field name string

---@class BeastieOpts
---@field beasties BeastieSet[]
---@field start_at_launch boolean
---@field animation_speed number
---@field active_beastie number

local function change_beastie_position()
  if not buf or not win then
    local active_set = config.beasties[config.active_beastie]
    buf, win, window_opts = ui.create_buffer_ui(active_set.frames[frame_idx])
  end

  local direction = math.random(4) -- 1: left, 2: right, 3: up, 4: down
  local step = math.random(1, 3)   -- Move 1 to 3 steps at a time

  if direction == 1 then           -- Move left
    window_opts.col = math.max(0, window_opts.col - step)
  elseif direction == 2 then       -- Move right
    window_opts.col = math.min(vim.o.columns - 3, window_opts.col + step)
  elseif direction == 3 then       -- Move up
    window_opts.row = math.max(0, window_opts.row - step)
  else                             -- Move down
    window_opts.row = math.min(vim.o.lines - 2, window_opts.row + step)
  end

  -- select random frame from active set
  local active_set = config.beasties[config.active_beastie]
  frame_idx = math.random(#active_set.frames)
  ui.update_beastie(buf, win, window_opts, active_set.frames[frame_idx])
end

local function start_beastie()
  log.info("Starting beastie ...")
  if timer then timer:stop() end
  timer = uv.new_timer()
  timer:start(0, config.animation_speed, vim.schedule_wrap(change_beastie_position))
end

local function stop_beastie()
  log.info("Stopping beastie ...")
  if timer then
    timer:stop(); timer = nil
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then vim.api.nvim_buf_delete(buf, { force = true }) end
  if win and vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  buf, win = nil, nil
end

-- Initialize default configuration
---@param opts BeastieOpts
local function initialize(opts)
  config = vim.tbl_deep_extend("force", {
    beasties = {
      {
        name = "cat",
        frames = { "🐱", "😺", "😸", "😹", "😼", "😽" }
      },
    },
    start_at_launch = false,
    animation_speed = 200,
    active_beastie = 1
  }, opts or {})
  frame_idx = 1
end

local function switch_beastie(index)
  if index > 0 and index <= #config.beasties then
    config.active_beastie = index
    frame_idx = 1
    if buf and win then
      -- Update the existing beastie if it's already running
      local active_set = config.beasties[config.active_beastie]
      ui.update_beastie(buf, win, window_opts, active_set.frames[frame_idx])
    end
    log.info("Switched to beastie set: " .. config.beasties[index].name)
  else
    log.error("Invalid beastie index")
  end
end

local function register_cmds()
  vim.api.nvim_create_user_command('BeastieStart', start_beastie, {})
  vim.api.nvim_create_user_command('BeastieStop', stop_beastie, {})
  vim.api.nvim_create_user_command('BeastieSwitch', function(opts)
    switch_beastie(tonumber(opts.args))
  end, { nargs = 1 })
end

function beastie.setup(opts)
  initialize(opts)
  register_cmds()
  if config.start_at_launch then
    vim.defer_fn(start_beastie, 1000)
  end
end

return beastie

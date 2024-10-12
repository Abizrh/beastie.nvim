local ui = require("beastie.ui")
local log = require("beastie.log")
local uv = require("beastie.uv")

local beastie = {}
local config, frame_idx, buf, win, window_opts, timer

local vicinity_radius = 2 -- max distance from cursor
local last_cursor_pos = { 0, 0 }
local jump_threshold = 5

---@class BeastieSet
---@field frames string[]
---@field name string

---@class BeastieOpts
---@field beasties BeastieSet[]
---@field start_at_launch boolean
---@field animation_speed number
---@field animation string
---@field active_beastie number

local function keep_within_vicinity(cursor_pos)
  if not window_opts then
    return
  end

  local dx = math.abs(window_opts.col - cursor_pos[2])
  local dy = math.abs(window_opts.row - (cursor_pos[1] - 1))

  if dx > vicinity_radius or dy > vicinity_radius then
    if dx > vicinity_radius then
      window_opts.col = cursor_pos[2] + math.random(-vicinity_radius, vicinity_radius)
    end
    if dy > vicinity_radius then
      window_opts.row = cursor_pos[1] - 1 + math.random(-vicinity_radius, vicinity_radius)
    end
  end
end

local function detect_cursor_jump(cursor_pos)
  local dx = cursor_pos[2] - last_cursor_pos[2]
  local dy = cursor_pos[1] - last_cursor_pos[1]

  if math.abs(dx) > jump_threshold or math.abs(dy) > jump_threshold then
    window_opts.col = cursor_pos[2] + math.random(-vicinity_radius, vicinity_radius)
    window_opts.row = math.max(0, cursor_pos[1] - 1 + math.random(-vicinity_radius, vicinity_radius))
  end
end

local function change_beastie_position()
  if not buf or not win then
    local active_set = config.beasties[config.active_beastie]
    buf, win, window_opts = ui.create_buffer_ui(active_set.frames[frame_idx])
  end

  if config.animation == "cursor" then
    local cursor_pos = vim.api.nvim_win_get_cursor(0)

    window_opts.col = cursor_pos[2] + math.random(-vicinity_radius, vicinity_radius)
    window_opts.row = cursor_pos[1] - 1 + math.random(-vicinity_radius, vicinity_radius)

    last_cursor_pos = { cursor_pos[1], cursor_pos[2] }
  end

  if config.animation == "random" then
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
  end

  local active_set = config.beasties[config.active_beastie]
  frame_idx = math.random(#active_set.frames)
  ui.update_beastie(buf, win, window_opts, active_set.frames[frame_idx])
end

local function start_beastie()
  log.info("Starting beastie ...")
  if timer then
    timer:stop()
  end
  timer = uv.new_timer()
  timer:start(
    0,
    config.animation_speed,
    vim.schedule_wrap(change_beastie_position)
  )
end

local function stop_beastie()
  log.info("Stopping beastie ...")
  if timer then
    timer:stop(); timer = nil
  end
  if buf and vim.api.nvim_buf_is_valid(buf) then
    vim.api.nvim_buf_delete(buf, { force = true })
  end
  if win and vim.api.nvim_win_is_valid(win) then
    vim.api.nvim_win_close(win, true)
  end
  buf, win = nil, nil
end

---@param opts BeastieOpts
local function initialize(opts)
  config = vim.tbl_deep_extend("force", {
    beasties = {
      {
        name = "cat",
        frames = { "🐱", "😺", "😸", "😹", "😼", "😽" },
      },
    },
    start_at_launch = false,
    animation_speed = 200,
    animation = "random",
    active_beastie = 1,
  }, opts or {})
  frame_idx = 1
end

local function switch_beastie(name)
  for i, set in ipairs(config.beasties) do
    if set.name == name then
      config.active_beastie = i
      frame_idx = 1
      if buf and win then
        local active_set = config.beasties[config.active_beastie]
        ui.update_beastie(buf, win, window_opts, active_set.frames[frame_idx])
      end
      log.info("Switched to beastie set: " .. config.beasties[i].name)
      return
    end
  end
end

local function register_cmds()
  vim.api.nvim_create_user_command("BeastieStart", start_beastie, {})
  vim.api.nvim_create_user_command("BeastieStop", stop_beastie, {})
  vim.api.nvim_create_user_command("BeastieSwitch", function(opts)
    switch_beastie(opts.args)
  end, { nargs = 1 })
end

function beastie.setup(opts)
  initialize(opts)
  register_cmds()
  if config.start_at_launch then
    vim.defer_fn(start_beastie, 1000)
  end
end

vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinScrolled" }, {
  callback = function()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    if config.animation == "cursor" and window_opts then
      keep_within_vicinity(cursor_pos)
      detect_cursor_jump(cursor_pos)
    end
  end,
})

return beastie

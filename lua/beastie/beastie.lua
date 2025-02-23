local ui = require("beastie.ui")
local log = require("beastie.log")
local uv = require("beastie.uv")

local beastie = {}
local config, timer
local active_beasties = {} -- Store multiple active beastie states

---@class BeastieState
---@field buf number
---@field win number
---@field window_opts table
---@field frame_idx number
---@field beastie_config BeastieSet

---@class BeastieSet
---@field frames string[]
---@field name string

---@class BeastieOpts
---@field beasties BeastieSet[]
---@field start_at_launch boolean
---@field animation_speed number
---@field animation string
---@field active_beastie number|string
---@field is_multiple boolean

local vicinity_radius = 0 -- max distance from cursor position
local last_cursor_pos = { 0, 0 }
local jump_threshold = 5

local function find_beastie_index(name)
  for i, set in ipairs(config.beasties) do
    if set.name == name then
      return i
    end
  end
  log.error("Beastie '" .. name .. "' not found!")
  return 1
end

local function open_cage()
  ui.create_buffer_cage_ui()
end

local function keep_within_vicinity(beastie_state, cursor_pos)
  if not beastie_state.window_opts then return end

  local dx = math.abs(beastie_state.window_opts.col - cursor_pos[2])
  local dy = math.abs(beastie_state.window_opts.row - (cursor_pos[1] - 1))

  if dx > vicinity_radius or dy > vicinity_radius then
    if dx > vicinity_radius then
      beastie_state.window_opts.col = cursor_pos[2] + math.random(-vicinity_radius, vicinity_radius)
    end
    if dy > vicinity_radius then
      beastie_state.window_opts.row = cursor_pos[1] - 1 + math.random(-vicinity_radius, vicinity_radius)
    end
  end
end

local function detect_cursor_jump(beastie_state, cursor_pos)
  local dx = cursor_pos[2] - last_cursor_pos[2]
  local dy = cursor_pos[1] - last_cursor_pos[1]

  if math.abs(dx) > jump_threshold or math.abs(dy) > jump_threshold then
    beastie_state.window_opts.col = cursor_pos[2] + math.random(-vicinity_radius, vicinity_radius)
    beastie_state.window_opts.row = math.max(0, cursor_pos[1] - 1 + math.random(-vicinity_radius, vicinity_radius))
  end
end

local function create_beastie_state(beastie_config)
  local frame_idx = 1
  local buf, win, window_opts = ui.create_buffer_ui(beastie_config.frames[frame_idx])

  if not buf or not win or not window_opts then
    log.error("Failed to create buffer ui for beastie: " .. beastie_config.name)
    return nil
  end

  if config.is_multiple then
    window_opts.row = math.random(ui.cage_bounds.row_min, ui.cage_bounds.row_max)
    window_opts.col = math.random(ui.cage_bounds.col_min, ui.cage_bounds.col_max)
  end

  return {
    buf = buf,
    win = win,
    window_opts = window_opts,
    frame_idx = frame_idx,
    beastie_config = beastie_config
  }
end

local function change_beastie_position()
  if not config then
    log.error("Configuration not initialized")
    return
  end

  for _, beastie_state in ipairs(active_beasties) do
    if config.animation == "random" then
      local direction = math.random(4)
      local step = math.random(1, 3)

      if direction == 1 then
        beastie_state.window_opts.col = math.max(ui.cage_bounds.col_min, beastie_state.window_opts.col - step)
      elseif direction == 2 then
        beastie_state.window_opts.col = math.min(ui.cage_bounds.col_max, beastie_state.window_opts.col + step)
      elseif direction == 3 then
        beastie_state.window_opts.row = math.max(ui.cage_bounds.row_min, beastie_state.window_opts.row - step)
      else
        beastie_state.window_opts.row = math.min(ui.cage_bounds.row_max, beastie_state.window_opts.row + step)
      end
    end

    if beastie_state.beastie_config and #beastie_state.beastie_config.frames > 0 then
      beastie_state.frame_idx = math.random(#beastie_state.beastie_config.frames)
      ui.update_beastie(
        beastie_state.buf,
        beastie_state.win,
        beastie_state.window_opts,
        beastie_state.beastie_config.frames[beastie_state.frame_idx]
      )
    end
  end
end

local function stop_beastie()
  log.info("Stopping beastie...")
  if timer then
    timer:stop()
    timer = nil
  end

  for _, beastie_state in ipairs(active_beasties) do
    if beastie_state.buf and vim.api.nvim_buf_is_valid(beastie_state.buf) then
      vim.api.nvim_buf_delete(beastie_state.buf, { force = true })
    end
    if beastie_state.win and vim.api.nvim_win_is_valid(beastie_state.win) then
      vim.api.nvim_win_close(beastie_state.win, true)
    end
  end
  active_beasties = {}

  if ui.cage_buf and vim.api.nvim_buf_is_valid(ui.cage_buf) then
    vim.api.nvim_buf_delete(ui.cage_buf, { force = true })
  end
  if ui.cage_win and vim.api.nvim_win_is_valid(ui.cage_win) then
    vim.api.nvim_win_close(ui.cage_win, true)
  end

  ui.cage_buf, ui.cage_win = nil, nil
end

local function start_beastie()
  log.info("Starting beastie...")

  stop_beastie()
  active_beasties = {}

  if config.is_multiple then
    open_cage()
  end

  if config.is_multiple and config.animation == 'random' then
    for _, beastie_config in ipairs(config.beasties) do
      local beastie_state = create_beastie_state(beastie_config)
      if beastie_state then
        table.insert(active_beasties, beastie_state)
      end
    end
  else
    local active_index = type(config.active_beastie) == "string"
        and find_beastie_index(config.active_beastie)
        or config.active_beastie
    local beastie_state = create_beastie_state(config.beasties[active_index])
    if beastie_state then
      table.insert(active_beasties, beastie_state)
    end
  end

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
    active_beastie = 'cat',
    is_multiple = false
  }, opts or {})

  if type(config.active_beastie) == "string" then
    config.active_beastie = find_beastie_index(config.active_beastie)
  end
end

local function switch_beastie(name)
  if not config or not config.beasties then
    log.error("Configuration not initialized")
    return
  end

  local new_index = find_beastie_index(name)
  config.active_beastie = new_index

  if config.is_multiple then
    start_beastie()
  else
    stop_beastie()
    start_beastie()
  end

  log.info("Switched to beastie set: " .. name)
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
    if not config then return end
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    if config.animation == "cursor" then
      for _, beastie_state in ipairs(active_beasties) do
        keep_within_vicinity(beastie_state, cursor_pos)
        detect_cursor_jump(beastie_state, cursor_pos)
      end
    end
    last_cursor_pos = cursor_pos
  end,
})

return beastie

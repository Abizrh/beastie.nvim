-- lua/beastie/config.lua
local M = {}

M.default_config = {
  frames = {
    "🐱", "😺", "😸", "😹", "😼", "😽"
  },
  animation_speed = 200, -- ms
}

M.options = {}

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", {}, M.default_config, opts or {})
end

return M

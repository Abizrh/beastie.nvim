local config = {}

config.default_config = {
  frames = {
    "🐱", "😺", "😸", "😹", "😼", "😽"
  },
  animation_speed = 200, -- ms
  start_at_launch = true,
  animation = "random" --options -> "random" | "cursor"
}

config.options = {}

function config.setup(opts)
  config.options = vim.tbl_deep_extend("force", {}, config.options, opts or {})
end

return config

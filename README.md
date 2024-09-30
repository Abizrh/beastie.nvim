# 🐱 beastie.nvim
A fun and lightweight Neovim plugin that brings emoji as your bastie's while coding.

## Usage

### Lazy

```lua
  {
    "Abizrh/beastie.nvim",
    lazy = false, -- needed so the beastie can start at launch
    opts = {
      frames = {
        "🐱",
        "😺",
        "😸",
        "😹",
        "😼", 
        "😽" 
      },
      start_at_launch = false,
      animation_speed = 400, -- ms
    },
  },
```

## Configuration

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| frames | table | { '🐻', '🐼', '🐨', '🦊', '🐶', '🐱' } | Sprites emojis |
| animation_speed | number | 200 | The speed of the animation |
| start_at_launch | boolean | false | Start the animation at launch |

## License

MIT

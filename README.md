# beastie.nvim
A fun and lightweight Neovim plugin that brings a moving pet or emoji as bastien's while coding.

## Installation

### Packer

```lua
use {
  'Abizrh/beastie.nvim',
  config = function()
    require('beastie').setup()
  end
}
```

### Lazy

```lua
{
  'Abizrh/beastie.nvim',
  config = function()
    require('beastie').setup()
  end
}
```

## Usage

```lua
require('beastie').setup({
  -- The emoji to use
  emoji = '🐻',
  -- Sprites emojis
  sprites = {
    '🐻',
    '🐼',
    '🐨',
    '🦊',
    '🐶',
    '🐱',
  },
  -- The speed of the animation
  speed = 10,
  -- The position of the animation
  position = 'center',
  -- The size of the animation
  size = 10,
  -- The color of the animation
  color = '#ff0000',
  -- The background color of the animation
  background_color = '#000000',
  -- The opacity of the animation
  opacity = 0.5,
  -- The animation type
  type = 'moving',
  -- The animation direction
  direction = 'left',
  -- The animation loop
  loop = true,
  -- The animation delay
  delay = 1000,
})
```

## Configuration

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| emoji | string | 🐻 | The emoji to use |
| sprites | table | { '🐻', '🐼', '🐨', '🦊', '🐶', '🐱' } | Sprites emojis |
| speed | number | 10 | The speed of the animation |
| position | string | center | The position of the animation |
| size | number | 10 | The size of the animation |
| color | string | #ff0000 | The color of the animation |
| background_color | string | #000000 | The background color of the animation |
| opacity | number | 0.5 | The opacity of the animation |
| type | string | moving | The animation type |
| direction | string | left | The animation direction |
| loop | boolean | true | The animation loop |
| delay | number | 1000 | The animation delay |

## License

MIT

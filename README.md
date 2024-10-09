
# 🐱 beastie.nvim
<a href="https://dotfyle.com/plugins/Abizrh/beastie.nvim">
  <img src="https://dotfyle.com/plugins/Abizrh/beastie.nvim/shield" />
</a>
<br/>
A fun and lightweight Neovim plugin that brings emoji as your bastie's while coding.



https://github.com/user-attachments/assets/ca2db35e-6ae5-45f2-87ef-9c4c9458ee78



## Installation

### Lazy

```lua
  {
    "Abizrh/beastie.nvim",
    lazy = false, -- needed so the your beastie can start at launch
    opts = {
      beasties = {
        {
          name = "cat",
          frames = { "🐱", "😺", "😸", "😹", "😼", "😽" }
        },
        {
          name = "dog",
          frames = { "🐶", "🐕", "🦮", "🐕" }
        },
        {
          name = "bird",
          frames = { "🐦", "🐤", "🐧", "🦜" }
        }
      },
      start_at_launch = true,
      animation_speed = 200, -- ms
      active_beastie = 1, -- 
    },
  },
```


## Usage

| Command               | Description                                             |
| --------------------- | ------------------------------------------------------- |
| `:BeastieStart`      | Start your Beastie                               |
| `:BeastieStop`       | Stop your Beastie                                |
| `:BeastieSwitch 2`         | Switch to a specific beastie [given index] |


## Configuration

| Option | Type | Default | Description |
| --- | --- | --- | --- |
| beastie | table | { {name = 'cat', frames = {'🐱', '😺', '😸', '😹', '😼', '😽'}} } | The list of beasties to choose from |
| animation_speed | number | 200 | The speed of the animation |
| start_at_launch | boolean | false | Start the animation at launch |
| active_beastie | number | 1 | The index of the active beastie |


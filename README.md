<!-- LTeX: enabled=false -->
# nvim-justice ⚖️
<!-- LTeX: enabled=true -->
<!-- TODO uncomment shields when available in dotfyle.com 
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-justice">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-justice/shield"/></a>
-->

Lightweight integration of [`just`](https://github.com/casey/just) in nvim.

<img alt="Showcase" width=50% src="https://github.com/user-attachments/assets/ae011582-61b2-41d0-b479-cc5eb9b1427d">

## Table of contents

<!-- toc -->

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [About the author](#about-the-author)

<!-- tocstop -->

## Features
- **Quick-select** recipes via keys shown at the left of the window. Running
  recipes thus requires only 2–3 keystrokes.
- Output results in a notification window or in the quickfix list.
- Supports streaming output (e.g., when a recipe outputs a progress bar.)
- Inspect recipes and variable values.
- Hide specific recipes, useful to always exclude recipes that require user
  input.

## Installation
**Requirements**
- nvim 0.10+
- [just](https://github.com/casey/just)
- *optional:* [snacks.nvim](http://github.com/folke/snacks.nvim) (required for
  streaming output)
- *optional:* Treesitter parser for syntax highlighting (`:TSInstall just`)

```lua
-- lazy.nvim
{
	"chrisgrieser/nvim-justice",
	keys = {
		{ "<leader>j", function() require("justice").select() end, desc = "Justice" },
	},
},

-- packer
use {
	"chrisgrieser/nvim-justice",
}
vim.keymap.set("n", "<leader>j", function() require("justice").select() end, { desc = "Justice" })
```

## Configuration
The `setup` call is optional.

```lua
-- default settings
require("justice").setup {
	recipes = {
		ignore = { "run-fzf" }, -- for recipes that require user input
		streaming = { "run-streaming" }, -- streams output, e.g. for progress bars (requires `snacks.nvim`)
		quickfix = {}, -- runs synchronously and sends output to quickfix list
		commentMaxLen = 35, -- truncate recipe comments if longer
	},
	keymaps = {
		next = "<Tab>",
		prev = "<S-Tab>",
		runRecipe = "<CR>",
		closeWin = { "q", "<Esc>" },
		quickSelect = { "f", "d", "s", "a" },
		showRecipe = "<Space>",
		showVariables = "?",
	},
	highlights = {
		quickSelect = "Conditional",
		icons = "Function",
	},
	icons = {
		just = "󰖷",
		streaming = "ﲋ",
		quickfix = "",
		ignore = "󰈉",
	},
}
```

## Usage
- `require("justice").select()`
- Navigate the window via `<Tab>` & `<S-Tab>`, select with `<CR>`.
- **Quick-select** recipes via keys shown at the left of the window.
- Show recipe via `<Space>`.

## About the author
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

I also occasionally blog about vim: [Nano Tips for Vim](https://nanotipsforvim.prose.sh)

- [Academic Website](https://chris-grieser.de/)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img
	height='36'
	style='border:0px;height:36px;'
	src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
	border='0'
	alt='Buy Me a Coffee at ko-fi.com'
/></a>

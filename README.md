<!-- LTeX: enabled=false -->
# nvim-justice ⚖️
<!-- LTeX: enabled=true -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-justice">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-justice/shield"/></a>

Just an integration of [`just`](https://github.com/casey/just) in nvim.

<img alt="Showcase" width=50% src="https://github.com/user-attachments/assets/ae011582-61b2-41d0-b479-cc5eb9b1427d">

## Table of contents

<!-- toc -->

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Advanced usage](#advanced-usage)
	* [Using progress bars and streaming output](#using-progress-bars-and-streaming-output)
- [About the author](#about-the-author)

<!-- tocstop -->

## Features
- **Quick-select** recipes via keys shown at the left of the window. Running
  recipes thus requires only 2–3 keystrokes.
- As opposed to vim's builtin `:make`, always runs **asynchronously**.
- Different run modes
	* **Default**: results are shown in a notification window
	* **Quickfix**: output is added to the quickfix list, using the
	  [errorformat](https://neovim.io/doc/user/quickfix.html#errorformat)
	* **Streaming**: useful for recipes with progress bars
	* **Terminal**: handy for recipes that require input
- Inspect recipes and variable values.
- Hide specific recipes, helpful to always exclude recipes that require user
  input.

## Installation
**Requirements**
- nvim 0.10+
- [just](https://github.com/casey/just)
- *optional:* [snacks.nvim](http://github.com/folke/snacks.nvim) (for streaming
  output)
- *optional:* Treesitter parser for syntax highlighting (`:TSInstall just`)

```lua
-- lazy.nvim
{ "chrisgrieser/nvim-justice" },

-- packer
use { "chrisgrieser/nvim-justice" }
```

## Configuration
The `setup` call is optional.

```lua
-- default settings
require("justice").setup {
	recipes = {
		-- All strings are checked via `string.find`, that is as lua patterns.
		-- (Note that in lua patterns, a `-` needs to escaped as `%-`.)
		streaming = { -- useful for progress bars (requires `snacks.nvim`)
			name = { "download" },
			comment = { "streaming", "curl" }, -- comment contains "streaming" or "curl"
		},
		terminal = { -- useful for recipes with input
			name = {},
			comment = { "input" },
		},
		quickfix = {
			name = { "%-qf$" }, -- name ending with "-qf"
			comment = { "quickfix" },
		},
		ignore = { -- hides them from the nvim-justice selection window
			name = { "fzf", "^_" }, -- ...if the name contains with "_"
			comment = {},
		},
	},
	terminal = {
		height = 10,
	},
	keymaps = {
		next = "<Tab>",
		prev = "<S-Tab>",
		runRecipeUnderCursor = "<CR>",
		runFirstRecipe = "1",
		closeWin = { "q", "<Esc>" },
		showRecipe = "<Space>",
		showVariables = "?",
		ignoreAsQuickfixKey = { "-", "_" },
	},
	window = {
		border = getBorder(), -- `vim.o.winborder` on nvim 0.11, otherwise "rounded"
		recipeCommentMaxLen = 35,
	},
	highlights = {
		quickSelect = "Keyword",
		icons = "Function",
	},
	icons = {
		just = "󰖷",
		streaming = "ﲋ",
		quickfix = "",
		terminal = "",
		ignore = "󰈉",
	},
}
```

## Usage

```lua
require("justice").select()
```

```vim
:Justice
```

**Keymaps**
- Navigate the window via `<Tab>` & `<S-Tab>`.
- Select with `<CR>`.
- **Quick-select** recipes via keys shown at the left of the window.
- Show recipe via `<Space>`.

**Use with a specific Justfile**

```lua
require("justice").select({
	justfile = "path/to/custom/justfile", -- passed to `--justfile=`
})
```

## Advanced usage

### Using progress bars and streaming output
Here is an example of a `just` recipe that displays a simple progress bar

This kind of progress bar works the same when triggered in the terminal via
`just demo-progressbar` and via `nivm-justice`.

```just
# `opts.recipes.streaming.comment` is configured to make recipes whose comment
# contains "streaming" stream the output

# streaming
demo-progressbar:
    #!/usr/bin/env zsh
    char="+"
    progress=""
    for i in {1..20}; do
        progress="$progress$char"
		printf "\33[2K\r" # `\33[2K` fully erase the line, `\r` moves to the BoL
        printf "$progress" # printf (or `echo -n`) needed to not create a newline
        sleep 0.1
    done
    printf "\33[2K\r"
    echo "Done."
```

Note that the following version of a progress bar works in the terminal, but
will not work in `nvim-justice`, since the plugin prints every unit of data
individually.

```just
# streaming
progressbar_not_working_in_nvim-justice:
    #!/usr/bin/env zsh
    char="+"
    for i in {1..20}; do
        printf "$char"
        sleep 0.1
    done
    printf "\33[2K\r"
    echo "Done."
```

## About the author
In my day job, I am a sociologist studying the social mechanisms underlying the
digital economy. For my PhD project, I investigate the governance of the app
economy and how software ecosystems manage the tension between innovation and
compatibility. If you are interested in this subject, feel free to get in touch.

- [Website](https://chris-grieser.de/)
- [Mastodon](https://pkm.social/@pseudometa)
- [ResearchGate](https://www.researchgate.net/profile/Christopher-Grieser)
- [LinkedIn](https://www.linkedin.com/in/christopher-grieser-ba693b17a/)

<a href='https://ko-fi.com/Y8Y86SQ91' target='_blank'><img height='36'
style='border:0px;height:36px;' src='https://cdn.ko-fi.com/cdn/kofi1.png?v=3'
border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

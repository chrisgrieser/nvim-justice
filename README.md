# nvim-justice ⚖️ <!-- rumdl-disable-line MD063 `nvim` lowercased -->
<a href="https://dotfyle.com/plugins/chrisgrieser/nvim-justice">
<img alt="badge" src="https://dotfyle.com/plugins/chrisgrieser/nvim-justice/shield"/></a>

Just an integration of [`just`](https://github.com/casey/just) in nvim.

<img alt="Showcase" width=40% src="https://github.com/user-attachments/assets/cb35d791-dd93-4deb-9566-8e574305ad5b">

## Table of contents

<!-- toc -->

- [Features](#features)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Advanced usage](#advanced-usage)
    - [Using progress bars and streaming output](#using-progress-bars-and-streaming-output)
- [More `just` tooling for nvim](#more-just-tooling-for-nvim)
- [About the author](#about-the-author)

<!-- tocstop -->

## Features
- **Quick-select** recipes via keys shown at the left of the window. Running
  recipes thus requires only 2–3 keystrokes.
- As opposed to vim's builtin `:make`, always runs **asynchronously**.
- **Modes** for running recipes:
    - **Default**: results are shown in a notification window
    - **Quickfix**: output is added to the quickfix list, using the
      [errorformat](https://neovim.io/doc/user/quickfix.html#errorformat)
    - **Streaming**: useful for example when the recipe has a progress bar
    - **Terminal**: useful for example when the recipe prompts for further input
- Support for `just`'s [run
  parameters](https://just.systems/man/en/recipe-parameters.html). Parameters
  are read via `vim.ui.input`.
- Inspect recipes and variable values.
- Hide specific recipes, helpful to always exclude recipes that require user
  input.

## Installation
**Requirements** <!-- rumdl-disable-line MD036 -->
- nvim 0.10+
- [just](https://github.com/casey/just)
- *optional:* [snacks.nvim](http://github.com/folke/snacks.nvim) (for streaming
  output)
- *optional:* `vim.ui.input` provider, such as
  [snacks.nvim](http://github.com/folke/snacks.nvim), for nicer recipe parameter
  input
- *optional:* Treesitter parser for syntax highlighting (`:TSInstall just`)

```lua
-- lazy.nvim
return { 
	"chrisgrieser/nvim-justice"
	-- optional, for streaming output and nicer parameter input
	-- dependencies = "folke/snacks.nvim",
}
```

## Configuration
The `setup` call is optional.

```lua
-- default settings
require("justice").setup {
	-- Defines how recipe modes are determined. For example, if a recipe has
	-- "download" in the name, or if it has "streaming" or "curl" in the comment,
	-- it will be considered a "streaming" recipe.
	-- (strings are interpreted as lua patterns, thus `-` needs to be escaped as `%-`)
	recipeModes = {
		streaming = { -- useful for progress bars (requires `snacks.nvim`)
			name = { "download" },
			comment = { "streaming", "curl" }, -- comment contains "streaming" or "curl"
		},
		terminal = { -- useful for recipes with input
			name = {},
			comment = { "input", "terminal", "fzf" },
		},
		quickfix = {
			name = { "%-qf$" }, -- name ending with "-qf"
			comment = { "quickfix" },
		},
		ignore = { -- hides them from the nvim-justice selection window
			name = {},
			comment = {},
		},
	},
	window = {
		border = getBorder(), -- `vim.o.winborder` on nvim 0.11, otherwise "rounded"
		recipeCommentMaxLen = 35,
		keymaps = {
			next = "<Tab>",
			prev = "<S-Tab>",
			runRecipeUnderCursor = "<CR>",
			runFirstRecipe = "1",
			closeWin = { "q", "<Esc>" },
			showRecipe = "<Space>",
			showVariables = "?",
			dontUseForQuickKey = { "j", "k", "-", "_" },
		},
		highlightGroups = {
			quickKey = "Keyword",
			icons = "Function",
		},
		icons = {
			just = "󰖷",
			streaming = "ﲋ",
			quickfix = "",
			terminal = "",
			ignore = "󰈉",
			recipeParameters = "󰘎",
		},
	},
	terminal = {
		height = 10,
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

**Recipe parameters** <!-- rumdl-disable-line MD036 -->
If the recipe expects [parameters from the command
line](https://just.systems/man/en/recipe-parameters.html), `nvim-justice` will
automatically prompt for them.

If a parameter default has been defined, confirm the prompt with an empty value
to use the default.

**Keymaps in the selection window** <!-- rumdl-disable-line MD036 -->
- Navigate the window via `<Tab>` & `<S-Tab>`.
- Run selected recipe with `<CR>`.
- **Quick-select** recipes via the highlighted keys.
- Run the first recipe via `1`.
- Inspect recipe via `<Space>`.
- Show variable values via `?`.

**Use with a specific Justfile (`--justfile`)**  

```lua
require("justice").select({
	justfile = "path/to/custom/justfile", -- passed to `--justfile=`
})
```

## Advanced usage

### Using progress bars and streaming output
Here is an example of a `just` recipe that displays a simple progress bar

This kind of progress bar works the same when triggered in the terminal via
`just demo-progressbar` or via `nivm-justice`.

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
		printf "\33[2K\r" # `\33[2K` fully erase the line, `\r` moves to start of line
        printf "$progress" # printf (or `echo -n`) needed to not create a newline
        sleep 0.1
    done
    printf "\33[2K\r"
    echo "Done."
```

Note that the following version of a progress bar works in the terminal, but
not work in `nvim-justice`, since the plugin prints every unit of data
individually.

```just
# streaming
progressbar_not_working_in_nvim_justice:
    #!/usr/bin/env zsh
    char="+"
    for i in {1..20}; do
        printf "$char"
        sleep 0.1
    done
    printf "\33[2K\r"
    echo "Done."
```

## More `just` tooling for nvim
- [Just-LSP](https://github.com/terror/just-lsp)
- [Treesitter parser for
  Just](https://github.com/IndianBoy42/tree-sitter-just) (`:TSInstall just`)

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

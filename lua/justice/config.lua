local M = {}
--------------------------------------------------------------------------------

---@class Justice.Config
local defaultConfig = {
	recipes = {
		-- All strings are checked via `string.find`, that is as lua patterns.
		-- (Note that in lua patterns, a `-` needs to escaped as `%-`.)
		ignore = { -- hides them from the nvim-justice selection window
			name = { "fzf", "^_" }, -- ...if the name contains "fzf" or starts with "_"
			comment = { "interactive" }, -- ...if the comment contains "interactive"
		},
		streaming = { -- streams output, e.g. for progress bars (requires `snacks.nvim`)
			name = { "download" },
			comment = { "streaming", "curl" }, -- comment with "streaming" or "curl"
		},
		quickfix = { -- runs synchronously and sends output to quickfix list
			name = { "%-qf$" }, -- name ending with "-qf"
			comment = { "quickfix" },
		},
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
	window = {
		border = "rounded",
		recipeCommentMaxLen = 35,
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

M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? Justice.Config
M.setup = function(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	-- DEPRECATION
	if
		M.config.recipes.ignore[1]
		or M.config.recipes.streaming[1]
		or M.config.recipes.quickfix[1]
	then
		local notify = require("justice.utils").notify
		notify("The `recipe` configuration has changed. Please refer to the README.", "warn")
	end
end

--------------------------------------------------------------------------------
return M

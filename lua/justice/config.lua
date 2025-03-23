local M = {}
--------------------------------------------------------------------------------

local fallbackBorder = "rounded"

---@return string
local function getBorder()
	local hasWinborder, winborder = pcall(function() return vim.o.winborder end)
	if not hasWinborder or winborder == "" or winborder == "none" then return fallbackBorder end
	return winborder
end

--------------------------------------------------------------------------------

---@class Justice.Config
local defaultConfig = {
	recipes = {
		-- All strings are checked via `string.find`, that is as lua patterns.
		-- (Note that in lua patterns, a `-` needs to escaped as `%-`.)
		streaming = { -- streams output, useful for progress bars (requires `snacks.nvim`)
			name = { "download" },
			comment = { "streaming", "curl" }, -- comment contains "streaming" or "curl"
		},
		terminal = { -- runs in terminal, useful for recipes with input
			name = {},
			comment = { "input" },
		},
		quickfix = { -- runs synchronously and sends output to quickfix list
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
		runRecipe = "<CR>",
		closeWin = { "q", "<Esc>" },
		quickSelect = { "f", "d", "s", "a" },
		showRecipe = "<Space>",
		showVariables = "?",
	},
	window = {
		border = getBorder(), -- `vim.o.winborder` on nvim 0.11, otherwise "rounded"
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
		terminal = "",
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

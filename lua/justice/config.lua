local M = {}
local u = require("justice.utils")
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
		quickSelect = "IncSearch",
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

	-- DEPRECATION (2024-11-23)
	if
		M.config.recipes.ignore[1]
		or M.config.recipes.streaming[1]
		or M.config.recipes.quickfix[1]
	then
		u.notify("The `recipe` configuration has changed. Please refer to the README.", "warn")
	end

	-- DEPRECATION (2025-04-23)
	if M.config.keymaps.runRecipe then
		local msg = "Config `keymaps.runRecipe` has been renamed to `keymaps.runRecipeUnderCursor`."
		u.notify(msg, "warn")
		M.config.keymaps.runRecipeUnderCursor = M.config.keymaps.runRecipe
		M.config.keymaps.runRecipe = nil -- prevent adding to `keysUsed`
	end
	if M.config.keymaps.quickSelect then
		local msg =
			"Config `keymaps.quickSelect` is now obsolete, keys are determined dynamically via recipe name."
		u.notify(msg, "warn")
		M.config.keymaps.quickSelect = nil -- prevent adding to `keysUsed`
	end

	-- VALIDATE
	if M.config.window.border == "none" or M.config.window.border == "" then
		M.config.window.border = fallbackBorder
		local msg = ('Border "none" is not supported, falling back to %q.'):format(fallbackBorder)
		u.notify(msg, "warn")
	end
end

--------------------------------------------------------------------------------
return M

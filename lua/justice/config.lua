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

M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? Justice.Config
M.setup = function(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})

	-- DEPRECATION (2025-08-02)
	---@diagnostic disable: undefined-field
	if M.config.recipes then u.warn("Config `recipes` has been renamed to `recipesModes`.") end
	if M.config.keymaps then u.warn("Config `keymaps` has been moved to `window.keymaps`.") end
	if M.config.icons then u.warn("Config `icons` has been moved to `window.icons`.") end
	if M.config.highlights then u.warn("Config `highlights` moved to `window.highlightGroups`.") end
	---@diagnostic enable: undefined-field

	-- VALIDATE
	if M.config.window.border == "none" or M.config.window.border == "" then
		M.config.window.border = fallbackBorder
		local msg = ('Border "none" is not supported, falling back to %q.'):format(fallbackBorder)
		u.replaceNotif(msg, "warn")
	end
end

--------------------------------------------------------------------------------
return M

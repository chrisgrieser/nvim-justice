local M = {}
--------------------------------------------------------------------------------

---@class Justice.Config
local defaultConfig = {
	recipes = {
		-- All strings here are checked via `string.find`, that is as lua
		-- patterns. For example, all recipes that contain `fzf` are ignored.
		-- (Note that in lua patterns, a `-` needs to escaped as `%-`.)
		ignore = { "fzf" }, -- for recipes that require user input
		streaming = { "streaming" }, -- streams output, e.g. for progress bars (requires `snacks.nvim`)
		quickfix = { "qf" }, -- runs synchronously and sends output to quickfix list
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
end

--------------------------------------------------------------------------------
return M

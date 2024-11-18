local M = {}
--------------------------------------------------------------------------------

---@class Justice.config
local defaultConfig = {
	recipes = {
		ignore = { "run-fzf" }, -- for recipes that require user input
		streaming = { "run-streaming" }, -- streams output, e.g. for progress bars (requires `snacks.nvim`)
		quickfix = {}, -- runs synchronously and sends output to quickfix list
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

---@param userConfig? Justice.config
M.setup = function(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})
end

--------------------------------------------------------------------------------
return M

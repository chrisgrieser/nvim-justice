local M = {}
--------------------------------------------------------------------------------

---@class Justice.config
local defaultConfig = {
	recipes = {
		quickfix = { "check-tsc" }, -- runs synchronously and sends output to quickfix list
		streaming = { "run-streaming" }, -- streams output, e.g. for progress bars (requires `snacks.nvim`)
		ignore = { "release", "run-fzf" }, -- for recipes that require user input
		commentMaxLen = 35, -- truncate recipe comments if longer
	},
	keymaps = {
		next = "<Tab>",
		prev = "<S-Tab>",
		runRecipe = "<CR>",
		closeWin = { "q", "<Esc>", "<D-w>" },
		quickSelect = { "j", "f", "d", "s", "a" },
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

M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? Justice.config
M.setup = function(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})
end

--------------------------------------------------------------------------------
return M

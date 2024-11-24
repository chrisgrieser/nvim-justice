local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Justice.Config
M.setup = function(userConfig) require("justice.config").setup(userConfig) end

--------------------------------------------------------------------------------

---@class Justice.RunOptions
---@field justfile? string

---@param opts? Justice.RunOptions
M.select = function(opts)
	if not opts then opts = {} end
	if opts.justfile then opts.justfile = vim.fs.normalize(opts.justfile) end

	local allRecipes = require("justice.get-recipes").get(opts)
	if not allRecipes then return end

	require("justice.selection-window").select(allRecipes)
end

--------------------------------------------------------------------------------
return M

local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Justice.config
M.setup = function(userConfig) require("justice.config").setup(userConfig) end

---@param opts? Justice.RunOptions
---@return Justice.RunOptions
local function prepareOpts(opts)
	if not opts then opts = {} end
	if opts.justfile then opts.justfile = vim.fs.normalize(opts.justfile) end
	return opts
end

---@param opts? Justice.RunOptions
M.select = function(opts)
	opts = prepareOpts(opts)
	local allRecipes = require("justice.get-recipes").get(opts)
	if not allRecipes then return end
	require("justice.selection-window").select(allRecipes)
end

--------------------------------------------------------------------------------
return M

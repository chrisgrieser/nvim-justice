local M = {}
--------------------------------------------------------------------------------

---@class Justice.Recipe
---@field name string
---@field comment string
---@field displayText string
---@field type? "streaming"|"quickfix"|"ignore"

---@param userConfig? Justice.config
M.setup = function(userConfig) require("justice.config").setup(userConfig) end

M.select = function()
	local allRecipes = require("justice.get-recipes").get()
	if not allRecipes then return end
	require("justice.selection-window").select(allRecipes)
end

--------------------------------------------------------------------------------
return M

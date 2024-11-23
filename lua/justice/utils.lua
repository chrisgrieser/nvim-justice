local M = {}
--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param opts? table
function M.notify(msg, level, opts)
	local config = require("justice.config").config
	if not level then level = "info" end
	if not opts then opts = {} end
	opts.id = "just-recipe" -- `snacks.nvim` replaces notifications of same id
	opts.icon = config.icons.just
	opts.title = opts.title and "Just: " .. opts.title or "Just"
	vim.notify(vim.trim(msg), vim.log.levels[level:upper()], opts)
end

---@param recipe Justice.Recipe
---@param ... string extra args to append
---@return string[] -- list of form { "just", ... }
function M.justArgs(recipe, ...)
	local args = { "just" }
	if recipe.justfile then table.insert(args, "--justfile=" .. recipe.justfile) end
	return vim.list_extend(args, { ... })
end

--------------------------------------------------------------------------------
return M

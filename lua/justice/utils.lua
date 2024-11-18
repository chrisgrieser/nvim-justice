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

--------------------------------------------------------------------------------
return M

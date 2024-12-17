local M = {}
--------------------------------------------------------------------------------

-- only snacks.nvim supports replacing notifications

function M.showRunningNotification(recipe)
	if not package.loaded["snacks"] then return end
	vim.notify("Running…", vim.log.levels.TRACE, { title = recipe.name, id = "justice.running" })
end

local function hideRunningNotification()
	if package.loaded["snacks"] then require("snacks").notifier.hide("justice.running") end
end

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param opts? table
function M.notify(msg, level, opts)
	hideRunningNotification()

	msg = vim.trim(msg)
	if msg == "" then return end

	if not level then level = "info" end
	if not opts then opts = {} end

	opts.id = "just-recipe" -- `snacks.nvim` replaces notifications of same id
	opts.icon = require("justice.config").config.icons.just
	opts.title = opts.title and "Just: " .. opts.title or "Just"
	vim.notify(msg, vim.log.levels[level:upper()], opts)
end

--------------------------------------------------------------------------------
return M

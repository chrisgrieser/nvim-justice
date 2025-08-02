local M = {}
--------------------------------------------------------------------------------

-- only snacks.nvim supports replacing notifications
function M.showRunningNotification(recipe)
	if not package.loaded["snacks"] then return end
	vim.notify("Running…", vim.log.levels.TRACE, { title = recipe.name, id = "justice.running" })
end

local function hideRunningNotification()
	if not package.loaded["snacks"] then return end
	require("snacks").notifier.hide("justice.running")
end

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---@param opts? table
function M.replaceNotif(msg, level, opts)
	vim.schedule(hideRunningNotification)

	msg = vim.trim(msg)
	if msg == "" then return end

	if not level then level = "info" end
	if not opts then opts = {} end

	opts.id = "just-recipe" -- `snacks.nvim` replaces notifications of same id
	opts.icon = opts.icon or require("justice.config").config.window.icons.just
	opts.title = opts.title and "Just: " .. opts.title or "Just"
	vim.notify(msg, vim.log.levels[level:upper()], opts)
end

---@param msg string
function M.warn(msg) vim.notify(msg, vim.log.levels.WARN, { title = "Just" }) end

--------------------------------------------------------------------------------
return M

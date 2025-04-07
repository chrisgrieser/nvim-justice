local M = {}

local u = require("justice.utils")
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@param recipe Justice.Recipe
---@param data string
---@param pastData string[]
---@return string[] updated pastData
---@nodiscard
local function streamOutput(recipe, data, pastData)
	if not data then return pastData end
	-- remove special escape sequence `\33[2K` which erases the line in the
	-- Terminal, but is only clutter in nvim
	data = vim.trim(data:gsub("%[2K", ""))
	if data == "" then return pastData end -- if line was erased, keep previous text

	-- severity not determined by being stderr, as many CLIs send non-errors to it
	local severity = "trace"
	if data:lower():find("warn") then severity = "warn" end
	if data:lower():find("error") then severity = "error" end
	notify(data, severity, { title = recipe.name })

	table.insert(pastData, data)
	return pastData
end

---@param recipe Justice.Recipe
---@param out vim.SystemCompleted
---@param pastData string[]
local function exitOutput(recipe, out, pastData)
	local text = (out.stdout or "") .. (out.stderr or "")
	if out.code ~= 0 then
		local justErrMsg = table.remove(pastData)
		local lastMsg = table.remove(pastData)
		text = vim.trim(lastMsg .. "\n" .. justErrMsg .. text)
	elseif vim.trim(text) == "" then
		text = table.remove(pastData)
	end

	-- change the severity of the last notification as additional visual
	-- indicator that the task is complete
	local severity = out.code == 0 and "info" or "error"

	notify(text, severity, { title = recipe.name })
	vim.cmd.checktime()
end

--------------------------------------------------------------------------------

---@param recipe Justice.Recipe
function M.runRecipe(recipe)
	vim.cmd("silent! update")

	-- PRE-RUN NOTIFICATION
	if recipe.type ~= "terminal" then u.showRunningNotification(recipe) end

	-- 1) STREAMING
	if recipe.type == "streaming" then
		if not package.loaded["snacks"] then
			local msg = "`snacks.nvim` is required for streaming output."
			notify(msg, "error", { title = recipe.name })
			return
		end
		local pastData = {}

		vim.system(recipe:shellArgs(recipe.name), {
			stdout = function(_, data) pastData = streamOutput(recipe, data, pastData) end,
			stderr = function(_, data) pastData = streamOutput(recipe, data, pastData) end,
		}, vim.schedule_wrap(function(out) exitOutput(recipe, out, pastData) end))
		return
	end

	-- 2) TERMINAL
	if recipe.type == "terminal" then
		vim.cmd.new() -- bottom split new window
		vim.cmd.terminal()
		local height = require("justice.config").config.terminal.height
		vim.api.nvim_win_set_height(0, height)

		local argStr = table.concat(recipe:shellArgs(recipe.name), " ")
		vim.api.nvim_chan_send(vim.bo.channel, argStr .. "\n") -- `\n` to send
		vim.cmd.startinsert { bang = true }
		return
	end

	-- 3) DEFAULT / QUICKFIX
	vim.system(
		recipe:shellArgs(recipe.name),
		{},
		vim.schedule_wrap(function(out)
			vim.cmd.checktime() -- reload in case of changes
			local text = (out.stdout or "") .. (out.stderr or "")

			if recipe.type == "quickfix" then
				local efm = vim.bo.efm ~= "" and vim.bo.efm or vim.o.efm
				vim.fn.setqflist({}, " ", {
					title = "just " .. recipe.name,
					lines = vim.split(text, "\n"),
					efm = efm,
				})
			else
				local severity = out.code == 0 and "info" or "error"
				notify(text, severity, { title = recipe.name })
			end
		end)
	)
end

--------------------------------------------------------------------------------

---@param recipe Justice.Recipe
function M.showRecipe(recipe)
	local args = recipe:shellArgs("--show", recipe.name)
	local stdout = vim.system(args):wait().stdout or "Error"
	notify(stdout, "trace", {
		title = recipe.name,
		ft = "just",
		-- if snacks.nvim, keep shown until win closed or manually dismissed
		timeout = not package.loaded["snacks"],
	})
end

---@param recipe Justice.Recipe
function M.showVariables(recipe)
	local args = recipe:shellArgs("--evaluate")
	local stdout = vim.system(args):wait().stdout or "Error"
	if vim.trim(stdout) == "" then
		notify("No variables defined.", "warn", { title = "Variables" })
	else
		notify(stdout, "trace", {
			title = "Variables",
			ft = "just",
			timeout = not package.loaded["snacks"],
		})
	end
end

--------------------------------------------------------------------------------
return M

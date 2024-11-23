local M = {}
local notify = require("justice.utils").notify
local justArgs = require("justice.utils").justArgs
--------------------------------------------------------------------------------

---@param recipe Justice.Recipe
function M.runRecipe(recipe)
	vim.cmd("silent! update")

	-- 1) QUICKFIX
	if recipe.type == "quickfix" then
		local prev = vim.bo.makeprg

		vim.bo.makeprg = "just"
		local argsStr = table.concat(justArgs(recipe, recipe.name), " ")
		vim.cmd.make(argsStr)

		pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
		vim.cmd.checktime() -- reload buffer in case of changes

		vim.bo.makeprg = prev
		return
	end

	-- PRE-RUN NOTIFICATION
	-- only snacks.nvim supports replacing notifications
	if package.loaded["snacks"] then notify("Running…", nil, { title = recipe.name }) end

	-- 2) STREAMING
	if recipe.type == "streaming" then
		if not package.loaded["snacks"] then
			local msg = "`snacks.nvim` is required for streaming output."
			notify(msg, "error", { title = recipe.name })
			return
		end
		local lastData = ""
		local function bufferedOut(_, data)
			if not data then return end
			-- severity not determined by stderr, as many CLIs send non-errors to it
			local severity = "trace"
			if data:lower():find("warn") then severity = "warn" end
			if data:lower():find("error") then severity = "error" end
			notify(data, severity, { title = recipe.name })
			lastData = data
		end
		vim.system(
			justArgs(recipe, recipe.name),
			{ stdout = bufferedOut, stderr = bufferedOut },
			vim.schedule_wrap(function(out)
				local text = (out.stdout or "") .. (out.stderr or "")
				if vim.trim(text) == "" then text = lastData end
				-- change the severity of the last notification as additional visual
				-- indicator that the task is complete
				local severity = out.code == 0 and "info" or "error"
				notify(text, severity, { title = recipe.name })
				vim.cmd.checktime()
			end)
		)
		return
	end

	-- 3) DEFAULT
	vim.system(
		justArgs(recipe, recipe.name),
		{},
		vim.schedule_wrap(function(out)
			vim.cmd.checktime()
			local text = (out.stdout or "") .. (out.stderr or "")
			local severity = out.code == 0 and "info" or "error"
			if vim.trim(text) == "" then return end
			notify(text, severity, { title = recipe.name })
		end)
	)
end

---@param recipe Justice.Recipe
function M.showRecipe(recipe)
	local args = justArgs(recipe, "--show", recipe.name)
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
	local args = justArgs(recipe, "--evaluate")
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

local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@param rec Justice.Recipe
function M.runRecipe(rec)
	vim.cmd("silent! update")

	-- 1) QUICKFIX
	if rec.type == "quickfix" then
		local prev = vim.bo.makeprg

		vim.bo.makeprg = "just"
		local argsStr = rec.justfile and "--justfile=" .. rec.justfile .. " " or ""
		argsStr = argsStr .. rec.name
		vim.cmd.make(argsStr)

		pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
		vim.cmd.checktime() -- reload buffer in case of changes
		vim.bo.makeprg = prev

		return
	end

	-- PRE-RUN NOTIFICATION
	-- only snacks.nvim supports replacing notifications
	if package.loaded["snacks"] then notify("Running…", nil, { title = rec.name }) end

	-- ARGS
	local args = {
		"just",
		rec.justfile and "--justfile=" .. rec.justfile or nil,
		rec.name,
	}
	args = vim.tbl_filter(function(a) return a end, args) -- remove nils

	-- 2) STREAMING
	if rec.type == "streaming" then
		if not package.loaded["snacks"] then
			local msg = "`snacks.nvim` is required for streaming output."
			notify(msg, "error", { title = rec.name })
			return
		end
		local function bufferedOut(_, data)
			if not data then return end
			-- severity not determined by stderr, as many CLIs send non-errors to it
			local severity = data:find("error") and "error" or "info"
			notify(data, severity, { title = rec.name })
		end
		vim.system(
			args,
			{ stdout = bufferedOut, stderr = bufferedOut },
			vim.schedule_wrap(function() vim.cmd.checktime() end)
		)
		return
	end

	-- 3) DEFAULT
	vim.system(
		args,
		{},
		vim.schedule_wrap(function(out)
			vim.cmd.checktime()
			local text = (out.stdout or "") .. (out.stderr or "")
			local severity = out.code == 0 and "info" or "error"
			if vim.trim(text) == "" then return end
			notify(text, severity, { title = rec.name })
		end)
	)
end

---@param recipe Justice.Recipe
function M.showRecipe(recipe)
	local args = {
		"just",
		recipe.justfile and "--justfile=" .. recipe.justfile or nil,
		"--show",
		recipe.name,
	}

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
	local args = {
		"just",
		recipe.justfile and "--justfile=" .. recipe.justfile or nil,
		"--evaluate",
	}

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

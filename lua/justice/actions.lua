local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@param recipe Recipe
function M.runRecipe(recipe)
	vim.cmd("silent! update")

	-- 1) QUICKFIX
	if recipe.type == "quickfix" then
		local prev = vim.bo.makeprg
		vim.bo.makeprg = "just"
		vim.cmd.make(recipe.name)
		vim.bo.makeprg = prev

		pcall(vim.cmd.cfirst) -- if there is a quickfix item, move to the 1st one
		vim.cmd.checktime() -- reload buffer in case of changes
		return
	end

	notify("Running…", nil, { title = recipe.name }) -- FIX also fixes snacks.nvim loop-backback error

	-- 2) STREAMING
	if recipe.type == "streaming" then
		if not package.loaded["snacks"] then
			local msg = "`snacks.nvim` is required for streaming output."
			notify(msg, "error", { title = recipe.name })
			return
		end
		local function bufferedOut(_, data)
			if not data then return end
			-- severity not determined by stderr, as many CLIs send non-errors to it
			local severity = data:find("error") and "error" or "info"
			notify(data, severity, { title = recipe.name })
		end
		vim.system(
			{ "just", recipe.name },
			{ stdout = bufferedOut, stderr = bufferedOut },
			vim.schedule_wrap(function() vim.cmd.checktime() end)
		)
		return
	end

	-- 3) DEFAULT
	vim.system(
		{ "just", recipe.name },
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

---@param recipe Recipe
function M.showRecipe(recipe)
	local stdout = vim.system({ "just", "--show", recipe.name }):wait().stdout or "Error"
	notify(stdout, "trace", {
		title = recipe.name,
		ft = "just",
		keep = function() return true end,
	})
end

function M.showVariables()
	local stdout = vim.system({ "just", "--evaluate" }):wait().stdout or "Error"
	if vim.trim(stdout) == "" then
		notify("No variables defined.", "warn", { title = "Variables" })
	else
		notify(stdout, "trace", {
			title = "Variables",
			ft = "just",
			keep = function() return true end,
		})
	end
end

--------------------------------------------------------------------------------
return M

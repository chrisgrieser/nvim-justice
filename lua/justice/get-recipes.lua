local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@nodiscard
---@return Recipe[]?
function M.get()
	-- in case user is currently editing a Justfile
	if vim.bo.filetype == "just" then vim.cmd("silent! update") end

	local config = require("justice.config").config

	local cmd = { "just", "--list", "--unsorted", "--list-heading=", "--list-prefix=" }
	local result = vim.system(cmd):wait()
	if result.code ~= 0 then
		notify(result.stderr, "error")
		return
	end
	local stdout = vim.split(result.stdout, "\n", { trimempty = true })

	local recipes = vim.iter(stdout)
		:map(function(line)
			local name, comment = line:match("^(%S+)%s*# (.+)")
			if comment then
				local max = config.window.recipeCommentMaxLen
				if #comment > max then comment = comment:sub(1, max) .. "…" end
			end
			if not name then name = line:match("^%S+") end
			local displayText = vim.trim(name .. "  " .. (comment or ""))

			local type
			if vim.tbl_contains(config.recipes.streaming, name) then type = "streaming" end
			if vim.tbl_contains(config.recipes.quickfix, name) then type = "quickfix" end
			if vim.tbl_contains(config.recipes.ignore, name) then type = "ignore" end

			return { name = name, comment = comment, type = type, displayText = displayText }
		end)
		:totable()
	return recipes
end

--------------------------------------------------------------------------------
return M

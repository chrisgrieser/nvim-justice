local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@param opts Justice.RunOptions
---@return Justice.Recipe[]?
---@nodiscard
function M.get(opts)
	-- in case user is currently editing a Justfile
	if vim.bo.filetype == "just" then vim.cmd("silent! update") end

	local config = require("justice.config").config

	local args = {
		"just",
		opts.justfile and "--justfile=" .. opts.justfile or nil,
		"--list",
		"--unsorted",
		"--list-heading=",
		"--list-prefix=",
	}

	local result = vim.system(args):wait()
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
			if vim.iter(config.recipes.ignore):any(function(pat) return name:find(pat) end) then
				type = "ignore"
			elseif vim.iter(config.recipes.streaming):any(function(pat) return name:find(pat) end) then
				type = "streaming"
			elseif vim.iter(config.recipes.quickfix):any(function(pat) return name:find(pat) end) then
				type = "quickfix"
			end

			return {
				name = name,
				comment = comment,
				type = type,
				displayText = displayText,
				justfile = opts.justfile,
			}
		end)
		:totable()
	return recipes
end

--------------------------------------------------------------------------------
return M

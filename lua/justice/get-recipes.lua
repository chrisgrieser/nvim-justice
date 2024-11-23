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
	args = vim.tbl_filter(function(a) return a end, args) -- remove nils

	local result = vim.system(args):wait()
	if result.code ~= 0 then
		notify(result.stderr, "error")
		return
	end
	local stdout = vim.split(result.stdout, "\n", { trimempty = true })

	local recipes = vim.iter(stdout)
		:map(function(line)
			local name, comment = line:match("^(%S+)%s*# (.+)")
			if not name then name = line:match("^%S+") end
			local displayComment = ""
			if comment then
				local max = config.window.recipeCommentMaxLen
				if #comment > max then displayComment = comment:sub(1, max) .. "…" end
			end
			local displayText = vim.trim(name .. "  " .. displayComment)

			local type
			for key, pattern in pairs(config.recipes) do
				local ignoreName = vim.iter(pattern.name)
					:any(function(pat) return name:find(pat) ~= nil end)
				local ignoreCom = vim.iter(pattern.comment)
					:any(function(pat) return (comment or ""):find(pat) ~= nil end)
				if ignoreName or ignoreCom then
					type = key
					break
				end
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

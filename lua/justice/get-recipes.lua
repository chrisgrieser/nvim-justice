local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@class Justice.Recipe
local Recipe = {
	name = "",
	comment = "",
	displayText = "",

	---@type "streaming"|"quickfix"|"ignore"|"terminal"|nil
	type = nil,
	---@type string?
	justfile = nil,

	---@return Justice.Recipe
	new = function(self, newObj)
		setmetatable(newObj, { __index = self }) -- https://www.lua.org/pil/16.1.html

		-- display text
		local config = require("justice.config").config
		local displayComment = ""
		if newObj.comment then
			local max = config.window.recipeCommentMaxLen
			if #newObj.comment > max then displayComment = newObj.comment:sub(1, max) .. "…" end
		end
		newObj.displayText = vim.trim(newObj.name .. "  " .. displayComment)

		-- recipe type
		for key, pattern in pairs(config.recipes) do
			local ignoreName = vim.iter(pattern.name)
				:any(function(pat) return newObj.name:find(pat) ~= nil end)
			local ignoreCom = vim.iter(pattern.comment)
				:any(function(pat) return (newObj.comment or ""):find(pat) ~= nil end)
			if ignoreName or ignoreCom then
				newObj.type = key
				break
			end
		end

		return newObj
	end,

	---@param self Justice.Recipe
	---@param ... string extra args to append
	---@return string[] -- list of form { "just", ... }
	shellArgs = function(self, ...)
		local args = { "just" }
		if self.justfile then table.insert(args, "--justfile=" .. self.justfile) end
		return vim.list_extend(args, { ... })
	end,
}

--------------------------------------------------------------------------------

---@param opts Justice.RunOptions
---@return Justice.Recipe[]?
---@nodiscard
function M.get(opts)
	-- in case user is currently editing a Justfile
	if vim.bo.filetype == "just" then vim.cmd("silent! update") end

	-- NOTE not using `just --dump --dump-format=json` because it does not
	-- preserve the order of recipes https://github.com/casey/just/issues/1552
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
			return Recipe:new {
				name = name,
				comment = comment,
				justfile = opts.justfile,
			}
		end)
		:totable()
	return recipes
end

--------------------------------------------------------------------------------
return M

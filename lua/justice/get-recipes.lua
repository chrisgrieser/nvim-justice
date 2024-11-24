local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@class Justice.Recipe
local Recipe = {
	name = "",
	comment = "",
	displayText = "",

	---@type "streaming"|"quickfix"|"ignore"|nil
	type = nil,
	---@type string?
	justfile = nil,

	---@return Justice.Recipe
	new = function(self, values)
		setmetatable(values, self) -- https://www.lua.org/pil/16.1.html
		self.__index = self

		-- display text
		local config = require("justice.config").config
		local displayComment = ""
		if values.comment then
			local max = config.window.recipeCommentMaxLen
			if #values.comment > max then displayComment = values.comment:sub(1, max) .. "…" end
		end
		values.displayText = vim.trim(values.name .. "  " .. displayComment)

		-- recipe type
		for key, pattern in pairs(config.recipes) do
			local ignoreName = vim.iter(pattern.name)
				:any(function(pat) return values.name:find(pat) ~= nil end)
			local ignoreCom = vim.iter(pattern.comment)
				:any(function(pat) return (values.comment or ""):find(pat) ~= nil end)
			if ignoreName or ignoreCom then
				values.type = key
				break
			end
		end

		return values
	end,

	---@param self Justice.Recipe
	---@param ... string extra args to append
	---@return string[] -- list of form { "just", ... }
	justArgs = function(self, ...)
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

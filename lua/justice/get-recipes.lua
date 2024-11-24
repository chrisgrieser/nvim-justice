local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@class Justice.Recipe
local Recipe = {
	name = "",
	comment = "",
	displayText = "",
	---@type string[]
	attributes = {},
	---@type "streaming"|"quickfix"|"ignore"|nil
	type = nil,
	---@type string?
	justfile = nil,

	---@return Justice.Recipe
	new = function(self, newObj)
		setmetatable(newObj, { __index = self }) -- https://www.lua.org/pil/16.1.html

		-- vim.json.decode() returns `vim.NIL` for `null` values
		if newObj.comment == vim.NIL then newObj.comment = nil end

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
		"--dump",
		"--dump-format=json",
	}
	args = vim.tbl_filter(function(a) return a end, args) -- remove nils

	local result = vim.system(args):wait()
	if result.code ~= 0 then
		notify(result.stderr, "error")
		return
	end

	local justDump = vim.json.decode(result.stdout)
	local recipes = vim.iter(justDump.recipes)
		:map(function(key, value)
			local r = Recipe:new {
				name = key,
				comment = value.doc,
				attributes = value.attributes, -- not used yet, just saved for future use
				justfile = opts.justfile,
			}
			return r
		end)
		:totable()
	return recipes
end

--------------------------------------------------------------------------------
return M

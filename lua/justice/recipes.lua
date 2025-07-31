local M = {}
local notify = require("justice.utils").notify
--------------------------------------------------------------------------------

---@class Justice.Recipe
local Recipe = {
	name = "",
	comment = "",
	displayText = "",
	type = nil, ---@type "streaming"|"quickfix"|"ignore"|"terminal"|nil
	justfile = nil, ---@type string? custom justfile provided by `--justfile=`

	parameterSpec = {}, ---@type {default: string|vim.NIL, export: boolean, kind: string, name: string}[]
	paramInputByUser = {}, ---@type string[]

	---@return Justice.Recipe
	new = function(self, newObj)
		setmetatable(newObj, { __index = self }) -- https://www.lua.org/pil/16.1.html
		self.paramInputByUser = {} -- reset from previous run

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
	---@return string[]
	getRunArgs = function(self)
		local args = { "just" }
		if self.justfile then table.insert(args, "--justfile=" .. self.justfile) end
		table.insert(args, self.name)
		vim.list_extend(args, self.paramInputByUser)
		return args
	end,
}

--------------------------------------------------------------------------------

---@param opts Justice.RunOptions
---@return Justice.Recipe[]?
---@nodiscard
function M.get(opts)
	-- in case user is currently editing a Justfile
	if vim.bo.filetype == "just" then vim.cmd("silent! update") end

	-- RECIPE ORDER
	-- NOTE `just --dump --dump-format=json` does not preserve the order of
	-- recipes, thus we need an extra run of `just --summary --unsorted`
	-- https://github.com/casey/just/issues/1552
	local args1 = {
		"just",
		"--summary",
		"--unsorted",
		opts.justfile and "--justfile=" .. opts.justfile or nil,
	}
	local result = vim.system(args1):wait()
	if result.code ~= 0 then
		notify(result.stderr, "error")
		return
	end
	local recipesInOrder = vim.split(vim.trim(result.stdout), " ")

	-- RECIPE METADATA
	local args2 = {
		"just",
		"--dump",
		"--dump-format=json",
		opts.justfile and "--justfile=" .. opts.justfile or nil,
	}
	local result2 = vim.system(args2):wait()
	if result2.code ~= 0 then
		notify(result2.stderr, "error")
		return
	end
	local recipeData = vim.json.decode(result2.stdout)

	-- MERGE THEM
	local recipes = vim.iter(recipesInOrder)
		:map(function(name)
			local data = recipeData.recipes[name]
			-- `vim.json.decode()` converts null values in the json to `vim.NIL`
			local comment = data.doc ~= vim.NIL and data.doc or nil
			local params = data.parameters
			if params.default == vim.NIL then params.default = nil end

			return Recipe:new {
				name = name,
				comment = comment,
				parameterSpec = params,
				justfile = opts.justfile,
			}
		end)
		:totable()
	return recipes
end

--------------------------------------------------------------------------------
return M

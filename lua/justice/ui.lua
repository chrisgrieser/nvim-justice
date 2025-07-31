local M = {}
local notify = require("justice.utils").notify
local actions = require("justice.actions")
--------------------------------------------------------------------------------

---@param recipe Justice.Recipe
local function promptForRunParameters(recipe)
	if #recipe.parameterSpec == 0 then
		actions.runRecipe(recipe)
		return
	end

	-- recursively call `vim.ui.input` for all parameters
	local function inputParam()
		local paramSpec = recipe.parameterSpec[#recipe.paramInputByUser + 1]
		local icon = require("justice.config").config.icons.just
		local prompt = ("%s Parameter %q for recipe %q "):format(icon, paramSpec.name, recipe.name)
		vim.ui.input({ prompt = prompt }, function(input)
			if not input then return end -- user aborted input
			if input == "" and paramSpec.default then input = paramSpec.default end
			table.insert(recipe.paramInputByUser, input)
			if #recipe.paramInputByUser < #recipe.parameterSpec then
				inputParam()
			else
				actions.runRecipe(recipe)
			end
		end)
	end
	inputParam()
end

--------------------------------------------------------------------------------

---@param allRecipes Justice.Recipe[]
function M.select(allRecipes)
	local config = require("justice.config").config
	local ns = vim.api.nvim_create_namespace("just-recipes")
	local title = " " .. vim.trim(config.icons.just .. " Justfile") .. " "

	-- prepare recipes for display
	local recipes = vim.tbl_filter(function(r) return r.type ~= "ignore" end, allRecipes) --[[@as Justice.Recipe[] ]]
	if #recipes == 0 then
		notify("After applying `recipes.ignore`, there are no left to choose from.", "warn")
		return
	end
	local ignoreCount = #allRecipes - #recipes
	local displayLines = vim.tbl_map(function(r) return " " .. r.displayText end, recipes)

	-- calculate window size
	local longestRecipe = vim.iter(recipes):fold(0, function(acc, r)
		local iconWidth = r.type and vim.api.nvim_strwidth(config.icons[r.type]) or 0
		local parameterWidth = #r.parameterSpec == 0 and 0
			or vim.api.nvim_strwidth(config.icons.recipeParameters) + 1
		local width = #r.displayText + iconWidth + parameterWidth
		return math.max(acc, width)
	end)
	local quickKeyWidth = 2
	local winWidth = math.max(longestRecipe, vim.api.nvim_strwidth(title)) + quickKeyWidth + 1
	local winHeight = math.min(#recipes, vim.api.nvim_win_get_height(0))

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, displayLines)
	local footer = (" %dx %s "):format(ignoreCount, config.icons.ignore)
	local winnr = vim.api.nvim_open_win(bufnr, true, {
		relative = "editor",
		row = (vim.o.lines - winHeight) / 2,
		col = (vim.o.columns - winWidth) / 2,
		width = winWidth,
		height = winHeight,
		border = config.window.border,
		style = "minimal",
		title = title,
		title_pos = "center",
		footer = ignoreCount > 0 and { { footer, "Comment" } } or nil,
		footer_pos = ignoreCount > 0 and "right" or nil,
	})
	vim.wo[winnr].sidescrolloff = 0
	vim.wo[winnr].winfixbuf = true
	vim.wo[winnr].cursorline = true
	vim.wo[winnr].colorcolumn = ""
	vim.bo[bufnr].modifiable = false

	-- highlight comments and add icons
	for i = 1, #recipes do
		if recipes[i].comment then
			if vim.hl.range then
				vim.hl.range(bufnr, ns, "Comment", { i - 1, #recipes[i].name + 1 }, { i - 1, -1 })
			else
				---@diagnostic disable-next-line: deprecated -- backwards compatibility
				vim.api.nvim_buf_add_highlight(bufnr, ns, "Comment", i - 1, #recipes[i].name, -1)
			end
		end
		if recipes[i].type then
			local icon = config.icons[recipes[i].type]
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, #recipes[i].name + 1, {
				virt_text = { { " " .. icon .. " ", config.highlights.icons } },
				virt_text_pos = "inline",
			})
		end
		local paramCount = #recipes[i].parameterSpec
		if paramCount > 0 then
			local virtText = (" %d%s "):format(paramCount, config.icons.recipeParameters)
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, #recipes[i].name + 1, {
				virt_text = { { virtText, config.highlights.icons } },
				virt_text_pos = "inline",
			})
		end
	end

	-- KEYMAPS
	local function closeWin()
		vim.api.nvim_win_close(winnr, true)
		if package.loaded["snacks"] then require("snacks").notifier.hide("just-recipe") end
	end
	local function runRecipe(ln)
		closeWin() -- close before run, so early notifications are not hidden
		promptForRunParameters(recipes[ln])
	end
	local function lnum() return vim.api.nvim_win_get_cursor(0)[1] end
	local function map(key, func) vim.keymap.set("n", key, func, { buffer = bufnr, nowait = true }) end

	-- general keymaps
	for _, key in pairs(config.keymaps.closeWin) do
		map(key, closeWin)
	end
	map(config.keymaps.next, function() vim.cmd.normal { "j", bang = true } end)
	map(config.keymaps.prev, function() vim.cmd.normal { "k", bang = true } end)
	map(config.keymaps.runRecipeUnderCursor, function() runRecipe(lnum()) end)
	map(config.keymaps.runFirstRecipe, function() runRecipe(1) end)
	map(config.keymaps.showRecipe, function() actions.showRecipe(recipes[lnum()]) end)
	map(config.keymaps.showVariables, function() actions.showVariables(recipes[lnum()]) end)

	-- quick-select keymaps
	local keysUsed = {}
	-- will add all keymaps from the config, including `ignoreAsQuickKey`
	vim.iter(vim.tbl_values(config.keymaps)):flatten():each(function(key) keysUsed[key] = true end)

	for i = 1, #recipes do
		local key
		local col = 0
		repeat
			col = col + 1
			key = recipes[i].name:sub(col, col)
		until not keysUsed[key] or key == ""
		if key ~= "" then
			keysUsed[key] = true
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, col, {
				hl_group = config.highlights.quickSelect,
				end_col = col + 1,
			})
			map(key, function() runRecipe(i) end)
		end
	end
end

--------------------------------------------------------------------------------
return M

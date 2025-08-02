local M = {}
local notify = require("justice.utils").replaceNotif
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
		local icon = require("justice.config").config.window.icons.just
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
	local icons = config.window.icons
	local hlgroups = config.window.highlightGroups
	local ns = vim.api.nvim_create_namespace("just-recipes")
	local title = " " .. vim.trim(icons.just .. " Justfile") .. " "

	-- prepare recipes for display
	local recipes = vim.tbl_filter(function(r) return r.mode ~= "ignore" end, allRecipes) --[[@as Justice.Recipe[] ]]
	if #recipes == 0 then
		notify("After applying `recipeModes.ignore`, no recipes left to choose from.", "warn")
		return
	end
	local ignoreCount = #allRecipes - #recipes
	local displayLines = vim.tbl_map(function(r) return " " .. r.displayText end, recipes)

	-- calculate window size
	local longestRecipe = vim.iter(recipes):fold(0, function(acc, r)
		---@cast r Justice.Recipe
		local iconWidth = r.mode and vim.api.nvim_strwidth(icons[r.mode]) or 0
		local parameterWidth = #r.parameterSpec == 0 and 0
			or vim.api.nvim_strwidth(icons.recipeParameters) + 1
		local width = #r.displayText + iconWidth + parameterWidth
		return math.max(acc, width)
	end)
	local quickKeyWidth = 2
	local winWidth = math.max(longestRecipe, vim.api.nvim_strwidth(title)) + quickKeyWidth + 1
	local winHeight = math.min(#recipes, vim.api.nvim_win_get_height(0))

	-- create window
	local bufnr = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, displayLines)
	local footer = (" %dx %s "):format(ignoreCount, icons.ignore)
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
		if recipes[i].mode then
			local icon = icons[recipes[i].mode]
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, #recipes[i].name + 1, {
				virt_text = { { " " .. icon .. " ", hlgroups.icons } },
				virt_text_pos = "inline",
			})
		end
		local paramCount = #recipes[i].parameterSpec
		if paramCount > 0 then
			local virtText = (" %d%s "):format(paramCount, icons.recipeParameters)
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, #recipes[i].name + 1, {
				virt_text = { { virtText, hlgroups.icons } },
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
	local keymaps = config.window.keymaps
	for _, key in pairs(keymaps.closeWin) do
		map(key, closeWin)
	end
	map(keymaps.next, function() vim.cmd.normal { "j", bang = true } end)
	map(keymaps.prev, function() vim.cmd.normal { "k", bang = true } end)
	map(keymaps.runRecipeUnderCursor, function() runRecipe(lnum()) end)
	map(keymaps.runFirstRecipe, function() runRecipe(1) end)
	map(keymaps.showRecipe, function() actions.showRecipe(recipes[lnum()]) end)
	map(keymaps.showVariables, function() actions.showVariables(recipes[lnum()]) end)

	-- quick-select keymaps
	local keysUsed = {}
	-- will add all keymaps from the config, including `ignoreAsQuickKey`
	vim.iter(vim.tbl_values(keymaps)):flatten():each(function(key) keysUsed[key] = true end)

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
				hl_group = hlgroups.quickSelect,
				end_col = col + 1,
			})
			map(key, function() runRecipe(i) end)
		end
	end
end

--------------------------------------------------------------------------------
return M

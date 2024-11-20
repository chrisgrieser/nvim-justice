local M = {}
local notify = require("justice.utils").notify
local actions = require("justice.actions")
--------------------------------------------------------------------------------

---@return integer
---@nodiscard
local function lnum() return vim.api.nvim_win_get_cursor(0)[1] end

---@param allRecipes Justice.Recipe[]
function M.select(allRecipes)
	local config = require("justice.config").config
	local ns = vim.api.nvim_create_namespace("just-recipes")
	local title = " " .. vim.trim(config.icons.just .. " Justfile") .. " "

	-- prepare recipes for display
	local recipes = vim.tbl_filter(function(r) return r.type ~= "ignore" end, allRecipes)
	if #recipes == 0 then
		notify("Justfile has no recipes.", "warn")
		return
	end
	local ignoreCount = #allRecipes - #recipes
	local displayLines = vim.tbl_map(function(r) return r.displayText end, recipes)

	-- calculate window size
	local longestRecipe = math.max(unpack(vim.tbl_map(function(r)
		local iconWidth = r.type and #config.icons[r.type] + 2 or 0
		return #r.displayText + iconWidth
	end, recipes)))
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
			vim.api.nvim_buf_add_highlight(bufnr, ns, "Comment", i - 1, #recipes[i].name, -1)
		end
		if recipes[i].type then
			local icon = config.icons[recipes[i].type]
			vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, #recipes[i].name, {
				virt_text = { { " " .. icon .. " ", config.highlights.icons } },
				virt_text_pos = "inline",
			})
		end
	end

	-- general keymaps
	local function closeWin()
		vim.api.nvim_win_close(winnr, true)
		local ok, snacks = pcall(require, "snacks")
		if ok then snacks.notifier.hide("just-recipe") end
	end
	local opts = { buffer = bufnr, nowait = true }
	local optsExpr = vim.tbl_extend("force", opts, { expr = true })
	for _, key in pairs(config.keymaps.closeWin) do
		vim.keymap.set("n", key, closeWin, opts)
	end
	vim.keymap.set("n", config.keymaps.next, function()
		if lnum() == #recipes then return "gg" end -- wrap
		return "j"
	end, optsExpr)
	vim.keymap.set("n", config.keymaps.prev, function()
		if lnum() == 1 then return "G" end -- wrap
		return "k"
	end, optsExpr)
	vim.keymap.set("n", config.keymaps.runRecipe, function()
		actions.runRecipe(recipes[lnum()])
		closeWin()
	end, opts)
	vim.keymap.set(
		"n",
		config.keymaps.showRecipe,
		function() actions.showRecipe(recipes[lnum()]) end,
		opts
	)
	vim.keymap.set(
		"n",
		config.keymaps.showVariables,
		function() actions.showVariables(recipes[lnum()]) end,
		opts
	)

	-- quick-select keymaps
	for i = 1, #recipes do
		local recipe = recipes[i] -- save since `i` changes
		local key = config.keymaps.quickSelect[i]
		if key then
			vim.keymap.set("n", key, function()
				actions.runRecipe(recipe)
				closeWin()
			end, opts)
		end
		vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
			virt_text = { { key or " ", config.highlights.quickSelect }, { " " } },
			virt_text_pos = "inline",
		})
	end
end

--------------------------------------------------------------------------------
return M

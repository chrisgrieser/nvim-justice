local M = {}
--------------------------------------------------------------------------------

---@class Justice.config
local defaultConfig = {
	enabled = true,
}

M.config = defaultConfig

--------------------------------------------------------------------------------

---@param userConfig? Justice.config
M.setup = function(userConfig)
	M.config = vim.tbl_deep_extend("force", defaultConfig, userConfig or {})
end

--------------------------------------------------------------------------------
return M

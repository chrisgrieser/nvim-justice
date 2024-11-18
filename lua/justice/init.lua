local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Justice.config
M.setup = function(userConfig) require("justice.config").setup(userConfig) end

--------------------------------------------------------------------------------
return M

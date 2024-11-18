local M = {}
--------------------------------------------------------------------------------

---@param userConfig? Justice.config
M.setup = function(userConfig) require("justice.config").setup(userConfig) end

M.select = function() require("justice.select-recipe").select() end

--------------------------------------------------------------------------------
return M

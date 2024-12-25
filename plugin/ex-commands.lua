vim.api.nvim_create_user_command(
	"Justice",
	function() require("justice").select() end,
	{ desc = "nvim-justice main command" }
)

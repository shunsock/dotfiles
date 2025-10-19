return {
  "brianhuster/autosave.nvim",
  event = { "InsertLeave", "TextChanged" },
  config = function()
    require("autosave").setup({
      enabled = true,
      execution_message = "AutoSave: 保存しました",
      events = {"InsertLeave", "TextChanged"},
      conditions = {
        exists = true,
        modifiable = true,
        filename_is_not = {},
        filetype_is_not = {}
      },
      write_all_buffers = false,
      debounce_delay = 135
    })
  end
}
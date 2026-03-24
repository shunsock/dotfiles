return {
  "github/copilot.vim",
  config = function()
    -- Copilotの設定
    vim.g.copilot_no_tab_map = true
    vim.g.copilot_filetypes = {
      ["*"] = true,
    }
  end
}
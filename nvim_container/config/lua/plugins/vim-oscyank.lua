return {
  "ojroques/nvim-osc52",
  event = "TextYankPost",
  config = function()
    require("osc52").setup {
      max_length = 0,   -- 無制限にコピー可能
      silent = true,    -- エコーを抑制
      trim = false,
    }

    local function copy()
      if vim.v.event.operator == "y" and vim.v.event.regname == "" then
        require("osc52").copy_register("")
      end
    end

    vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
  end,
}


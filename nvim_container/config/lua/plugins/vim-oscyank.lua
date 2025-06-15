return {
  "ojroques/nvim-osc52",
  priority = 1000, -- 高優先度で先に読み込む
  lazy = false,    -- 遅延読み込みしない
  config = function()
    require("osc52").setup {
      max_length = 0,   -- 無制限にコピー可能
      silent = true,    -- エコーを抑制
      trim = false,
    }

    -- プラグインをロードする前にクリップボード設定
    -- これにより最初のyank時のエラーを防止
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = function(lines)
          require('osc52').copy(table.concat(lines, '\n'))
        end,
        ['*'] = function(lines)
          require('osc52').copy(table.concat(lines, '\n'))
        end,
      },
      paste = {
        ['+'] = function()
          return { vim.fn.getreg('+') }
        end,
        ['*'] = function()
          return { vim.fn.getreg('*') }
        end,
      },
      cache_enabled = true,
    }

    local function copy()
      if vim.v.event.operator == "y" and vim.v.event.regname == "" then
        require("osc52").copy_register("")
      end
    end

    vim.api.nvim_create_autocmd("TextYankPost", { callback = copy })
  end,
}


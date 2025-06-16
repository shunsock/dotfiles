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
    -- vim.g.clipboard = {
    --   name = 'OSC 52',
    --   copy = {
    --     ['+'] = function(lines)
    --       require('osc52').copy(table.concat(lines, '\n'))
    --     end,
    --     ['*'] = function(lines)
    --       require('osc52').copy(table.concat(lines, '\n'))
    --     end,
    --   },
    --   paste = {
    --     ['+'] = function()
    --       return { vim.fn.getreg('+') }
    --     end,
    --     ['*'] = function()
    --       return { vim.fn.getreg('*') }
    --     end,
    --   },
    --   cache_enabled = true,
    -- }
    
    -- クリップボードプロバイダの設定
    -- 警告メッセージを抑制しつつ、yank/pasteの機能を維持
    vim.g.clipboard = {
      name = 'myClipboard',
      copy = {
        ['+'] = function(lines)
          vim.fn.setreg('+', table.concat(lines, '\n'))
        end,
        ['*'] = function(lines)
          vim.fn.setreg('*', table.concat(lines, '\n'))
        end,
      },
      paste = {
        ['+'] = function()
          return vim.fn.split(vim.fn.getreg('+'), '\n')
        end,
        ['*'] = function()
          return vim.fn.split(vim.fn.getreg('*'), '\n')
        end,
      },
      cache_enabled = false,
    }

    -- OSC52経由でクリップボードにコピーする機能（システム間コピー用）
    local function copy_with_osc52()
      if vim.v.event.operator == "y" then
        -- 無名レジスタまたは+/*レジスタの場合のみOSC52でコピー
        local regname = vim.v.event.regname
        if regname == "" or regname == "+" or regname == "*" then
          local content = vim.fn.getreg(regname == "" and '"' or regname)
          if content and content ~= "" then
            require("osc52").copy(content)
          end
        end
      end
    end

    -- テキストがyankされた後に実行
    vim.api.nvim_create_autocmd("TextYankPost", { callback = copy_with_osc52 })
  end,
}


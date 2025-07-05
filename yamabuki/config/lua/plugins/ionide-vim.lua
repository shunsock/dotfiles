return {
  'ionide/Ionide-vim',
  ft = { 'fsharp' },
  config = function()
    -- Ionide-vimの基本設定
    vim.g['fsharp#backend'] = 'nvim'
    vim.g['fsharp#automatic_workspace_init'] = 1
    vim.g['fsharp#lsp_auto_setup'] = 1
    vim.g['fsharp#lsp_recommended_colorscheme'] = 1
    vim.g['fsharp#lsp_codelens'] = 1
    
    -- F# Interactive設定
    vim.g['fsharp#fsi_command'] = 'dotnet fsi'
    vim.g['fsharp#fsi_keymap'] = 'vscode'
    vim.g['fsharp#fsi_window_command'] = 'botright 10new'
    vim.g['fsharp#fsi_focus_on_send'] = 0
    
    -- リンター設定
    vim.g['fsharp#linter'] = 1
    vim.g['fsharp#unused_opens_analyzer'] = 1
    vim.g['fsharp#unused_declarations_analyzer'] = 1
    
    -- エディタ設定
    vim.g['fsharp#automatic_reload_workspace'] = 1
    vim.g['fsharp#show_signature_on_cursor_move'] = 0
    
    -- F#ファイルを開いたときに自動でdotnet tool restoreを実行
    vim.api.nvim_create_autocmd({"BufEnter", "BufNewFile"}, {
      pattern = {"*.fs", "*.fsx", "*.fsi"},
      callback = function()
        -- プロジェクトルートを探す
        local project_root = vim.fn.finddir('.git', '.;')
        if project_root == '' then
          project_root = vim.fn.findfile('*.fsproj', '.;')
          if project_root ~= '' then
            project_root = vim.fn.fnamemodify(project_root, ':h')
          end
        else
          project_root = vim.fn.fnamemodify(project_root, ':h')
        end
        
        if project_root ~= '' then
          -- バックグラウンドでdotnet tool restoreを実行
          vim.fn.jobstart(
            'dotnet tool restore',
            {
              cwd = project_root,
              on_exit = function(_, code)
                if code == 0 then
                  vim.notify("dotnet tool restore completed", vim.log.levels.INFO)
                end
              end
            }
          )
        end
      end
    })
  end,
}
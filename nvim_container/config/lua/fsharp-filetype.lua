-- F#ファイルタイプの設定
vim.filetype.add({
  extension = {
    fs = "fsharp",
    fsi = "fsharp",
    fsx = "fsharp",
  },
})

-- F#ファイル用の追加設定
vim.api.nvim_create_autocmd("FileType", {
  pattern = "fsharp",
  callback = function()
    vim.bo.commentstring = "// %s"
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
    vim.bo.expandtab = true
    
    -- F#ファイルが開かれたことをログ出力
    print("F# file detected: " .. vim.fn.expand("%:t"))
  end,
})
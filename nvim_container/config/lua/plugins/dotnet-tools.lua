return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "fsharp" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- .NET project toolsの自動インストール設定
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "fsharp",
        callback = function()
          local cwd = vim.fn.getcwd()
          
          -- .NET tools manifestの確認と作成
          local manifest_path = cwd .. "/.config/dotnet-tools.json"
          if vim.fn.filereadable(manifest_path) == 0 then
            -- dotnet tool manifestを作成
            vim.fn.system("dotnet new tool-manifest")
            
            -- Fantomasツールのインストール
            vim.fn.system("dotnet tool install fantomas")
          end
          
          -- NuGet復元の実行
          local fsproj_files = vim.fn.glob("*.fsproj", false, true)
          if #fsproj_files > 0 then
            vim.fn.system("dotnet restore")
          end
        end,
      })
    end,
  },
}
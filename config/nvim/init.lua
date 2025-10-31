-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
return {
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  -- 他のプラグイン
}

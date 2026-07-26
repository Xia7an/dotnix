-- ~/.config/nvim/lua/plugins/image.lua

return {
  "3rd/image.nvim",
  ft = { "markdown" },
  -- svg はサイズや行の長さ次第で snacks.nvim の bigfile 判定により
  -- filetype が "svg" ではなく "bigfile" に上書きされてしまうことがあるため、
  -- FileType イベントではなくファイル名パターンで直接ロードする
  event = { "BufReadPre *.svg", "BufNewFile *.svg" },
  cond = function()
    if vim.fn.executable("magick") == 0 and vim.fn.executable("convert") == 0 then
      vim.notify("image.nvim requires ImageMagick. Run: brew install imagemagick", vim.log.levels.WARN)
      return false
    end
    return true
  end,
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true,
        only_render_image_at_cursor = false,
        floating_windows = false,
      },
    },
    -- *.svg を開いたバッファをそのまま画像としてレンダリングする
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.svg" },
    max_height_window_percentage = 50,
  },
}

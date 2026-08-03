-- macOS では nixpkgs の clang-tools 版 clangd を使わず、Xcode 付属のものを使う。
--
-- nix の clangd はラッパで nix 側の libc++ / libSystem のヘッダを CPATH に注入するが、
-- 実際の sysroot は Xcode SDK になるため両者が混ざり、`#include <vector>` だけの
-- ファイルでも `use_of_empty_using_if_exists` で解析が止まってしまう。
-- /usr/bin/clangd は SDK と整合するのでこちらに差し替える。
-- (clang-format は Xcode に含まれないので nix の clang-tools 自体は引き続き必要)
if vim.fn.has("mac") == 0 or vim.fn.executable("/usr/bin/clangd") == 0 then
  return {}
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local clangd = vim.tbl_get(opts, "servers", "clangd")
      if clangd and clangd.cmd then
        clangd.cmd[1] = "/usr/bin/clangd"
      end
    end,
  },
}

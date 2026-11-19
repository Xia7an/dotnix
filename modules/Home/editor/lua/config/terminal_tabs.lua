-- 右下のターミナル用ウィンドウを1つ固定で使い回し、そこに表示する
-- ターミナル(タブ)を複数保持して H / L で切り替えられるようにするモジュール。
-- 編集中ファイルの bufferline(タブ一覧)とは完全に独立した仕組み。
--
-- Snacks.terminal() は各ウィンドウに「自分のバッファ以外が表示されたら
-- 元に戻す」BufWinEnter フックを付けるため、そこへ直接 nvim_win_set_buf で
-- 別タブのバッファを差し込むと衝突して無限再帰(E218)になる。
-- そのため、ここではターミナルバッファを Snacks を介さず素の jobstart で
-- 自前管理する。
local M = {}

---@type integer?
local win = nil
---@type integer[]
local tabs = {}
local current = 0

local function win_valid()
  return win ~= nil and vim.api.nvim_win_is_valid(win)
end

-- 右下のターミナル用ウィンドウを確保する。
-- 既存のタブがどこかの窓にまだ表示されていればそれを使い、
-- なければ右側編集ウィンドウの下に新しく分割して作る。
local function ensure_win()
  if win_valid() then
    return win
  end

  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(w)
    if vim.tbl_contains(tabs, buf) then
      win = w
      return win
    end
  end

  vim.cmd("wincmd l")
  vim.cmd("belowright split")
  vim.api.nvim_win_set_height(0, 15)
  win = vim.api.nvim_get_current_win()
  return win
end

local function set_winbar()
  if not win_valid() then
    return
  end
  if #tabs <= 1 then
    vim.wo[win].winbar = ""
    return
  end
  vim.wo[win].winbar = string.format("Terminal %d/%d  (H/L: switch, <leader>tn: new)", current, #tabs)
end

local function show(idx)
  if not tabs[idx] then
    return
  end
  current = idx
  local w = ensure_win()
  vim.api.nvim_win_set_buf(w, tabs[idx])
  set_winbar()
end

--- 右下ウィンドウに新しいターミナルタブを開く
function M.new()
  local w = ensure_win()

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = "snacks_terminal"
  vim.bo[buf].swapfile = false
  vim.bo[buf].bufhidden = "hide"

  vim.api.nvim_win_set_buf(w, buf)
  vim.api.nvim_win_call(w, function()
    vim.fn.termopen(vim.o.shell)
  end)

  table.insert(tabs, buf)
  current = #tabs
  set_winbar()

  vim.keymap.set("n", "H", M.prev, { buffer = buf, desc = "Prev terminal tab" })
  vim.keymap.set("n", "L", M.next, { buffer = buf, desc = "Next terminal tab" })

  -- Esc を2回(200ms以内)で Terminal-mode を抜けて Normal-mode に戻る。
  -- 1回目はそのままシェル/nested vim 等に素通しするので、ターミナル内で
  -- 動かしている vim や fzf の Esc を壊さない
  local esc_timer
  vim.keymap.set("t", "<esc>", function()
    esc_timer = esc_timer or (vim.uv or vim.loop).new_timer()
    if esc_timer:is_active() then
      esc_timer:stop()
      return "<c-\\><c-n>"
    end
    esc_timer:start(200, 0, function() end)
    return "<esc>"
  end, { buffer = buf, expr = true, desc = "Double escape to normal mode" })

  -- Terminal-mode から直接 Ctrl+hjkl でウィンドウ移動(Terminal-mode を
  -- 抜けてから <c-w>hjkl するのと同じ)。ただし隣に窓が無い方向は生のキーを
  -- そのままターミナルへ通す(例: 下ドック端末の Ctrl+j = Claude Code の改行)
  local function smart_nav(dir)
    return function()
      if vim.fn.winnr(dir) == vim.fn.winnr() then
        return "<c-" .. dir .. ">"
      end
      return "<c-\\><c-n><c-w>" .. dir
    end
  end

  for _, dir in ipairs({ "h", "j", "k", "l" }) do
    vim.keymap.set("t", "<c-" .. dir .. ">", smart_nav(dir), {
      buffer = buf,
      expr = true,
      desc = "Window " .. dir .. " (or passthrough)",
    })
  end

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      for i, b in ipairs(tabs) do
        if b == buf then
          table.remove(tabs, i)
          break
        end
      end
      if current > #tabs then
        current = #tabs
      end
      if current > 0 then
        show(current)
      else
        set_winbar()
      end
    end,
  })
end

--- 右下ターミナルの表示/非表示をトグルする。
--- - どこかのウィンドウにターミナルタブが表示中なら、そのウィンドウを閉じて隠す
---   (バッファ=シェルのプロセスは生かしたまま。次回また復帰できる)
--- - 表示されていなければ、直前のタブを右下に復帰する。タブが1つも無ければ新規作成
function M.toggle()
  for _, w in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(w)
    if vim.tbl_contains(tabs, buf) then
      -- 表示中 → 隠す(bufhidden="hide" なのでプロセスは残る)
      win = nil
      vim.api.nvim_win_close(w, false)
      return
    end
  end

  -- 非表示 → 復帰、または新規
  if #tabs > 0 then
    if current < 1 or current > #tabs then
      current = #tabs
    end
    show(current)
    if win_valid() then
      vim.api.nvim_set_current_win(win)
      vim.cmd("startinsert")
    end
  else
    M.new()
  end
end

--- 次のターミナルタブに切り替える(末尾なら先頭に戻る)
function M.next()
  if #tabs == 0 then
    return
  end
  show(current % #tabs + 1)
end

--- 前のターミナルタブに切り替える(先頭なら末尾に戻る)
function M.prev()
  if #tabs == 0 then
    return
  end
  show((current - 2) % #tabs + 1)
end

return M

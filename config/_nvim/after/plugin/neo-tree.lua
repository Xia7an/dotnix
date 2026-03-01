-- Neo-tree file manager configuration (LazyVim style)
local folder_icons = require("plugins.neo-tree-icons").folder_icons

require("neo-tree").setup({
  close_if_last_window = true,
  popup_border_style = "rounded",
  enable_git_status = true,
  enable_diagnostics = true,
  
  sources = { "filesystem", "buffers", "git_status" },
  open_files_do_not_replace_types = { "terminal", "Trouble", "trouble", "qf", "Outline" },
  
  default_component_configs = {
    indent = {
      indent_size = 2,
      padding = 1,
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "󰜌",
      default = "*",
    },
    modified = {
      symbol = "[+]",
      highlight = "NeoTreeModified",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
    },
    git_status = {
      symbols = {
        added     = "",
        modified  = "",
        deleted   = "✖",
        renamed   = "󰁕",
        untracked = "",
        ignored   = "",
        unstaged  = "󰄱",
        staged    = "",
        conflict  = "",
      }
    },
  },
  
  -- Custom renderers
  renderers = {
    directory = {
      { "indent" },
      { "icon" },
      { "current_filter" },
      {
        "container",
        content = {
          { "name", zindex = 10 },
          {
            "symlink_target",
            zindex = 10,
            highlight = "NeoTreeSymbolicLinkTarget",
          },
          { "clipboard", zindex = 10 },
          { "diagnostics", errors_only = true, zindex = 20, align = "right", hide_when_expanded = true },
          { "git_status", zindex = 20, align = "right", hide_when_expanded = true },
        },
      },
    },
    file = {
      { "indent" },
      { "icon" },
      {
        "container",
        content = {
          {
            "name",
            zindex = 10,
          },
          {
            "symlink_target",
            zindex = 10,
            highlight = "NeoTreeSymbolicLinkTarget",
          },
          { "clipboard", zindex = 10 },
          { "bufnr", zindex = 10 },
          { "modified", zindex = 20, align = "right" },
          { "diagnostics", zindex = 20, align = "right" },
          { "git_status", zindex = 20, align = "right" },
        },
      },
    },
  },
  
  window = {
    position = "left",
    width = 30,
    mappings = {
      ["<space>"] = {
        "toggle_node",
        nowait = false,
      },
      ["<cr>"] = "open",
      ["<esc>"] = "cancel",
      ["P"] = { "toggle_preview", config = { use_float = true } },
      ["l"] = "focus_preview",
      ["S"] = "open_split",
      ["s"] = "open_vsplit",
      ["t"] = "open_tabnew",
      ["C"] = "close_node",
      ["z"] = "close_all_nodes",
      ["a"] = {
        "add",
        config = {
          show_path = "none"
        }
      },
      ["A"] = "add_directory",
      ["d"] = "delete",
      ["r"] = "rename",
      ["y"] = "copy_to_clipboard",
      ["x"] = "cut_to_clipboard",
      ["p"] = "paste_from_clipboard",
      ["c"] = "copy",
      ["m"] = "move",
      ["q"] = "close_window",
      ["R"] = "refresh",
      ["?"] = "show_help",
    }
  },
  
  filesystem = {
    filtered_items = {
      visible = false,
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_hidden = true,
    },
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    group_empty_dirs = false,
    hijack_netrw_behavior = "open_default",
    use_libuv_file_watcher = true,
    window = {
      mappings = {
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["/"] = "fuzzy_finder",
        ["D"] = "fuzzy_finder_directory",
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["[g"] = "prev_git_modified",
        ["]g"] = "next_git_modified",
      },
    },
  },
  
  buffers = {
    follow_current_file = {
      enabled = true,
      leave_dirs_open = false,
    },
    group_empty_dirs = true,
    show_unloaded = true,
  },
  
  git_status = {
    window = {
      position = "float",
      mappings = {
        ["A"]  = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      }
    }
  },
})

-- Custom event handler to apply folder icons
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    -- This is a workaround to add custom folder icons
    -- We'll use nvim-web-devicons to set custom icons
    local ok, devicons = pcall(require, "nvim-web-devicons")
    if ok then
      -- Override folder icons using web-devicons
      devicons.set_icon({
        Downloads = { icon = "󰉍", color = "#3daee9", name = "Downloads" },
        Documents = { icon = "󱧶", color = "#6da6e9", name = "Documents" },
        Pictures = { icon = "󰉏", color = "#c678dd", name = "Pictures" },
        Videos = { icon = "", color = "#fd971f", name = "Videos" },
        Music = { icon = "󱍙", color = "#98c379", name = "Music" },
        Desktop = { icon = "", color = "#61afef", name = "Desktop" },
        [".git"] = { icon = "", color = "#f34f29", name = "Git" },
        [".github"] = { icon = "", color = "#6e5494", name = "GitHub" },
        [".config"] = { icon = "", color = "#6d8086", name = "Config" },
        src = { icon = "", color = "#519aba", name = "Src" },
        test = { icon = "󰙨", color = "#cbcb41", name = "Test" },
        tests = { icon = "󰙨", color = "#cbcb41", name = "Tests" },
        docs = { icon = "", color = "#6da6e9", name = "Docs" },
        nvim = { icon = "", color = "#57a143", name = "Neovim" },
      })
    end
  end,
})

-- Keymaps
vim.keymap.set('n', '<leader>e', ':Neotree toggle<CR>', { desc = 'Toggle file explorer', silent = true })
vim.keymap.set('n', '<leader>E', ':Neotree reveal<CR>', { desc = 'Reveal current file', silent = true })
vim.keymap.set("n", "<leader>fe", function()
  require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
end, { desc = "Explorer NeoTree (cwd)" })
vim.keymap.set("n", "<leader>fE", function()
  require("neo-tree.command").execute({ toggle = true, dir = vim.fn.expand("%:p:h") })
end, { desc = "Explorer NeoTree (current file)" })






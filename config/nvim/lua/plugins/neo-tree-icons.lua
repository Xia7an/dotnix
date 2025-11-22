-- Custom icons for common folders
local M = {}

-- Folder icon mappings
M.folder_icons = {
  -- Home directories
  ["Downloads"] = { icon = "󰉍", hl = "NeoTreeDirectoryIcon" },
  ["Documents"] = { icon = "󱧶", hl = "NeoTreeDirectoryIcon" },
  ["Pictures"] = { icon = "󰉏", hl = "NeoTreeDirectoryIcon" },
  ["Music"] = { icon = "󱍙", hl = "NeoTreeDirectoryIcon" },
  
  -- Development folders
  [".git"] = { icon = "", hl = "NeoTreeGitIgnored" },
  ["node_modules"] = { icon = "", hl = "NeoTreeDimText" },
  [".github"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  [".config"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["src"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["test"] = { icon = "󰙨", hl = "NeoTreeDirectoryIcon" },
  ["tests"] = { icon = "󰙨", hl = "NeoTreeDirectoryIcon" },
  ["docs"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["bin"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["lib"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["build"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["dist"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  
  -- Config folders
  ["nvim"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["vim"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  
  -- Other common folders
  ["Public"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
  ["Templates"] = { icon = "", hl = "NeoTreeDirectoryIcon" },
}

return M

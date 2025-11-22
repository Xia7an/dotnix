#!/usr/bin/env bash
# Test script to verify Neovim configuration

echo "=== Neovim Configuration Test ==="
echo ""

# Test 1: Check if config files exist
echo "1. Checking configuration files..."
if [ -f ~/.config/nvim/lua/plugins/neo-tree.lua ]; then
  echo "   ✓ neo-tree.lua exists"
else
  echo "   ✗ neo-tree.lua NOT FOUND"
fi

if [ -f ~/.config/nvim/lua/plugins/neo-tree-icons.lua ]; then
  echo "   ✓ neo-tree-icons.lua exists"
else
  echo "   ✗ neo-tree-icons.lua NOT FOUND"
fi

if [ -f ~/.config/nvim/lua/plugins/which-key.lua ]; then
  echo "   ✓ which-key.lua exists"
else
  echo "   ✗ which-key.lua NOT FOUND"
fi

echo ""
echo "2. Testing plugin loading..."
nvim --headless -c "lua local ok = pcall(require, 'plugins.neo-tree-icons'); print(ok and '   ✓ neo-tree-icons loads' or '   ✗ neo-tree-icons FAILED')" -c "qa" 2>&1 | grep "✓\|✗"
nvim --headless -c "lua local ok = pcall(require, 'neo-tree'); print(ok and '   ✓ neo-tree loads' or '   ✗ neo-tree FAILED')" -c "qa" 2>&1 | grep "✓\|✗"
nvim --headless -c "lua local ok = pcall(require, 'which-key'); print(ok and '   ✓ which-key loads' or '   ✗ which-key FAILED')" -c "qa" 2>&1 | grep "✓\|✗"

echo ""
echo "3. Testing custom icons..."
nvim --headless -c "lua local icons = require('plugins.neo-tree-icons').folder_icons; print('   Downloads: ' .. (icons.Downloads and icons.Downloads.icon or 'NOT FOUND')); print('   Documents: ' .. (icons.Documents and icons.Documents.icon or 'NOT FOUND'))" -c "qa" 2>&1 | grep "Downloads\|Documents"

echo ""
echo "=== Test Complete ==="
echo ""
echo "To use Neovim with new configuration:"
echo "1. Close ALL Neovim instances"
echo "2. Open nvim"
echo "3. Press <Space> (wait a moment for which-key menu)"
echo "4. Press <Space>e to open Neo-tree file explorer"
echo "5. You should see custom folder icons"
echo ""

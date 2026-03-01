#!/usr/bin/env fish
# code-flags.confを更新
echo "--enable-wayland-ime" > ~/.config/code-flags.conf
echo "--enable-features=UseOzonePlatform,WaylandWindowDecorations" >> ~/.config/code-flags.conf
echo "--ozone-platform=wayland" >> ~/.config/code-flags.conf
echo "--gtk-version=4" >> ~/.config/code-flags.conf
echo "--disable-features=WaylandTextInputV3" >> ~/.config/code-flags.conf
echo "--ime-mode=async" >> ~/.config/code-flags.conf

cat ~/.config/code-flags.conf
echo ""
echo "VSCodeを再起動してください"

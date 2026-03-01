# fcitx5の設定を更新
mkdir -p ~/.config/fcitx5/conf
cat > ~/.config/fcitx5/conf/waylandim.conf << 'CONF'
DetectApplication=True
PreferKeyEvent=False
PersistentVirtualKeyboard=False
CONF

# code-flags.confを更新
cat > ~/.config/code-flags.conf << 'CONF'
--enable-wayland-ime
--enable-features=UseOzonePlatform,WaylandWindowDecorations
--ozone-platform=wayland
--gtk-version=4
--disable-features=WaylandTextInputV3
CONF

export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export GLFW_IM_MODULE=fcitx
export XMODIFIERS=@im=fcitx

killall fcitx5
sleep 1
fcitx5 -d
sleep 1

code

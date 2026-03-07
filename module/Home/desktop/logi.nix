{ pkgs, ... }: {
	# Logicool / Logitech デバイス管理ツール
	# ※ Nixpkgs では Logi Options+ は未提供のため、代替として logiops を使用
	home.packages = with pkgs; [
		logiops
		solaar
	];
}

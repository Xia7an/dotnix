# ディスクマウント設定例

NixOS で追加ディスクをマウントするには、`fileSystems` オプションを使います。

## 例: UUID を使ってディスクをマウント

```nix
# Atropos.nix または Nyx.nix に追加
fileSystems."/mnt/data" = {
  device = "/dev/disk/by-uuid/YOUR-UUID-HERE";
  fsType = "ext4";  # または "ntfs-3g", "btrfs" など
  options = [ "defaults" "nofail" ];
};
```

## UUID の確認方法

```bash
# すべてのディスクの UUID を表示
sudo blkid

# 特定のデバイスの UUID を表示
sudo blkid /dev/sdb1
```

## 注意事項

- `nofail` オプションを使うと、ディスクが接続されていなくても起動できます
- NTFS ディスクをマウントする場合は `fsType = "ntfs-3g"` を使用
- 自動マウントを有効にする場合は `options = [ "defaults" "auto" ]` を追加

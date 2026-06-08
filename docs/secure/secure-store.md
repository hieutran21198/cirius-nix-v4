
## Steps to make a secure store

```txt
mkdir -p /home/cirius/Workspaces/.vaults
chmod 700 /home/cirius/Workspaces/.vaults

fallocate -l 1G /home/cirius/Workspaces/.vaults/secret-store.luks
chmod 600 /home/cirius/Workspaces/.vaults/secret-store.luks

sudo cryptsetup luksFormat --type luks2 /home/cirius/Workspaces/.vaults/secret-store.luks
sudo cryptsetup open /home/cirius/Workspaces/.vaults/secret-store.luks secret-store

sudo mkfs.btrfs -L secret-store /dev/mapper/secret-store

sudo mkdir -p /mnt/secret-store
sudo mount -o compress=zstd,noatime /dev/mapper/secret-store /mnt/secret-store
```

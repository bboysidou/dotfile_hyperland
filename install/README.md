# Install

Boot the Arch ISO in UEFI mode (Secure Boot off), connect to the internet, then run:

```sh
curl -fsSL https://raw.githubusercontent.com/bboysidou/dotfile_hyperland/main/install.sh -o install.sh
bash install.sh
```

Options:

- `bash install.sh --dry-run` prints every command without changing anything.
- `bash install.sh --branch <name>` installs another branch of the dotfiles.

The log is written to `/tmp/installer/install.log` and copied to `/var/log/installer.log` on the new system.

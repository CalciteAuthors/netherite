# Netherite

This is a reincarnation of Netherite, a hardened Linux distribution based on Calcite.

It currently aims to replicate some of, largely the most important parts of secureblue's hardening, albeit in a more minimal way.

Currently the installation process is similar to secureblue's; install Calcite and then rebase to our image:

```bash
systemd-run -t bootc switch ghcr.io/calciteauthors/netherite:a10s --apply
```

## Features

- hardened_malloc
- `time.cifelli.xyz` time server (w/ NTS)
- Trivalent instead of Firefox
- usbguard (you'll need to configure it yourself)
- NetworkManager privacy
- Hardened kernel tunables
- run0 instead of sudo
- countme disabled

## Adding Flathub

Please use this command, as this only allows verified apps:

```bash
flatpak remote-add --if-not-exists --subset=verified flathub-verified https://flathub.org/repo/flathub.flatpakrepo
```

Or if you already enabled it, please run:

```bash
flatpak remote-modify --subset=verified flathub
```

# my_scripts

A personal collection of shell scripts for automating development environment setup and system configuration.

---

## 📁 Repository Structure

```
my_scripts/
├── rdp_lxqt/         # Remote desktop environment setup (LXQt + XRDP + Docker + VS Code)
└── README.md
```

> More scripts will be added over time as new automation needs arise.

---

## Scripts

### `rdp_lxqt/`

Sets up a complete remote desktop development environment on a fresh Ubuntu system. Intended for quickly provisioning a new machine or server you want to access remotely.

**What it does:**

1. Creates a new sudo user with a password you specify
2. Adds the Microsoft VS Code apt repository and installs VS Code
3. Updates and upgrades all system packages
4. Installs the **LXQt** desktop environment with **SDDM** display manager
5. Installs and enables **XRDP** for RDP access
6. Configures `.xsession` for the new user to launch LXQt on connect
7. Removes any conflicting legacy Docker packages
8. Installs the latest **Docker Engine** (CE), CLI, containerd, Buildx, and Compose plugin
9. Enables and starts the Docker service

**Requirements:**

- Ubuntu (tested on Ubuntu-based systems; Docker repo uses `$VERSION_CODENAME`)
- Must be run as **root** or with `sudo`

**Usage:**

```bash
sudo bash setup.sh
```

You will be prompted to enter:
- A new username
- A password for that user

**After running:**

Connect to the machine via any RDP client (e.g. Windows Remote Desktop, Remmina) using the new user's credentials.

> ⚠️ **Note:** This script modifies system-level packages and creates user accounts. Review it before running on any production system.

---

## Requirements

Scripts in this repo generally target **Ubuntu**. Individual scripts may have additional requirements — see each script's section above.

---

## Contributing

This is a personal scripts repo, but if you spot a bug or have a suggestion, feel free to open an issue.

---

## License

MIT

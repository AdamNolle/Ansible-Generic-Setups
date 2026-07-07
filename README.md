# 🧼 Ansible-Generic-Setups

Set up **anyone's** Mac, Windows, or Linux machine fast — debloated, privacy-hardened,
and preloaded with the apps normal people actually use. One command per computer.

Nothing personal is baked in: no private dotfiles, SSH keys, git identity, or
personal app choices. It's a clean, reusable baseline you can run on any machine
someone hands you.

> Re-running is always safe — every role is idempotent (a second run changes nothing).

---

## ⚡ Quick start

| Machine | Run this on it |
|---|---|
| 🍎 **macOS** | `curl -fsSL https://raw.githubusercontent.com/AdamNolle/Ansible-Generic-Setups/main/bootstrap/mac.sh \| bash` |
| 🐧 **Linux** (Debian/Ubuntu) | `curl -fsSL https://raw.githubusercontent.com/AdamNolle/Ansible-Generic-Setups/main/bootstrap/linux.sh \| bash` |
| 🪟 **Windows** | Run `bootstrap/windows.ps1` in an **elevated** PowerShell, then provision it over SSH from a Mac/Linux/WSL control node (the script prints the exact command). |

Or clone the repo and run directly:

```bash
ansible-galaxy collection install -r requirements.yml
ansible-playbook site.yml --limit mac                       # on a Mac
ansible-playbook site.yml --limit linux -K                  # on a Linux box
ansible-playbook site.yml --limit windows -K -e win_profile=standard   # from a control node
```

---

## 🪟 Windows — the big one

**Aggressive debloat + privacy, done for you.** A System Restore point is created
*first* so you can always roll back.

- **Removes** the AppX bloat: Solitaire, Clipchamp, Teams (consumer), Bing News/Weather,
  Cortana, OneNote/Office hub, Skype, Maps, People, 3D Viewer, Phone Link, "Media Player"
  (Zune), Widgets — **and every Copilot / Recall / AI surface**.
- **Removes OEM junk** on store-bought PCs: HP/Dell/Lenovo/Acer/ASUS/MSI bloatware,
  plus McAfee/Norton/SupportAssist trials.
- **Removes OneDrive** (your files in `~/OneDrive` are left on disk).
- **Kills telemetry**: diagnostic data off, ad ID off, DiagTrack service off, the whole
  CEIP scheduled-task set disabled, Start/Search/Lock-screen ads and web suggestions off.
- **Installs** the everyday apps (see below).
- ✅ **Keeps the visual polish** — transparency **and** animation effects stay **ON**.
  Debloat removes bloat, not the nice-looking UI. No mouse/keyboard/theme "feel" changes
  are imposed either.

**Two profiles** (you're prompted, or pass `-e win_profile=…`):
- `standard` — a normal person's PC.
- `developer` — adds a dev toolchain (VS Code, Git, Node, Python, Neovim, Terminal,
  PowerShell 7) and enables WSL2.

Edit the lists in [`group_vars/windows.yml`](group_vars/windows.yml) to taste.

---

## 🍎 macOS & 🐧 Linux

**macOS** installs via Homebrew and applies a few safe Finder defaults (show file
extensions, path bar) — nothing that changes how the machine feels.
**Linux** installs Brave from its official apt repo, LibreOffice, and flatpaks from Flathub.

---

## 📦 Apps installed (default)

| | Windows (winget) | macOS (brew) | Linux (apt/flatpak) |
|---|---|---|---|
| Browser | **Brave**, Chrome | **Brave**, Chrome | **Brave** |
| Office | **Microsoft 365 / Office** | **Microsoft Office** | LibreOffice + OnlyOffice¹ |
| Media | VLC, Spotify | VLC, Spotify | VLC, Spotify |
| Meetings | Zoom | Zoom | Zoom |
| Utilities | 7-Zip, PowerToys, Acrobat Reader | The Unarchiver | timeshift |

¹ Microsoft Office has no native Linux app — use it in the browser, or the included
OnlyOffice/LibreOffice for local editing.

Office signs in with **the user's own** Microsoft account/license — it's the real
suite, just installed for them.

---

## 🔧 Change what it does

Everything is a plain-text manifest — edit and re-run:

| To change… | Edit |
|---|---|
| Windows apps + debloat/privacy | [`group_vars/windows.yml`](group_vars/windows.yml) + [`profiles/`](profiles/) |
| Mac apps + defaults | [`group_vars/mac.yml`](group_vars/mac.yml) |
| Linux apps | [`group_vars/linux.yml`](group_vars/linux.yml) |
| DNS (default: Cloudflare) | [`group_vars/all.yml`](group_vars/all.yml) |

**Requirements:** Ansible 2.16+ and the collections in
[`requirements.yml`](requirements.yml) (`community.general`, `ansible.windows`,
`community.windows`).

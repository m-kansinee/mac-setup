# macOS Bootstrap Ansible Playbook

A modular and idempotent Ansible Playbook designed to bootstrap new MacBook Apple Silicon machines. This project follows a "Configuration as Code" approach to manage software installations and system preferences. Tested on macOS Tahoe 26.3.

## 🚀 Features

- **Modular Design**: Separated roles for Homebrew, Dotfiles (Chezmoi), Fish, System Settings, VS Code, and tmux.
- **Categorized Apps**: Homebrew applications are organized into `general`, `developer`, and `ai` categories.
- **Fish Shell by Default**: Configures Fish with `Fisher` and selected plugins for a modern terminal experience.
- **VS Code Optimization**: Automatically installs extensions for Claude-powered AI development and web applications.
- **Idempotency**: Safe to run multiple times; only applies changes where needed.

---

## 🛠️ Step-by-Step Setup

### 1. Configure Your Variables

Before running, open `group_vars/all.yml` and update:

- **`dotfiles_repo`**: Set to your chezmoi dotfiles repository URL.
- **`osx_computer_name`**: Set your machine name, or leave as `"TODO"` to be prompted on first run.
- **`homebrew_formulae`** / **`homebrew_casks`**: Add or remove packages as needed.
- **`vscode_extensions`**: Modify the extension list as needed.
- **`fish_plugins`**: Modify the plugin list as needed.

Each role also has a `defaults/main.yml` for role-specific overrides:

| Role | Key defaults |
|------|-------------|
| `dotfiles` | `dotfiles_branch` (default: `master`, auto-detected from remote) |
| `fish` | `fish_bin_path` (default: `/opt/homebrew/bin/fish`) |
| `system` | `dock_remove_apps`, `dock_add_apps`, `terminal_font_name`, `terminal_font_size` |
| `vscode` | `vscode_config_files` |

### 2. Run the Bootstrap Script

A single script handles all prerequisites (Xcode CLI Tools, Homebrew, Ansible, collections) and then runs the playbook:

```bash
chmod +x bootstrap.sh
./bootstrap.sh
```

You will be prompted to:
1. Enter a computer name (only if `osx_computer_name` is still `"TODO"`)
2. Enter your macOS password for sudo tasks

### 3. Restart Your Terminal

After the playbook completes, restart your terminal to enter Fish shell.

---

## ▶️ Running the Playbook Directly

If Ansible is already installed:

```bash
# Full run
ansible-playbook main.yml --ask-become-pass

# Dry run (no changes applied)
ansible-playbook main.yml --ask-become-pass --check

# Skip the group prompt and install specific groups
ansible-playbook main.yml --ask-become-pass -e selected_groups_prompt="general,developer"

# Install Ansible collections manually
ansible-galaxy collection install -r requirements.yml
```

---

## 📂 Project Structure

- `bootstrap.sh` — One-command entry point. Installs Xcode CLT, Homebrew, Ansible, then runs the playbook.
- `main.yml` — Main Ansible playbook. Prompts for group selection and computer name, then runs all roles.
- `requirements.yml` — Ansible Galaxy collection dependencies (`community.general`).
- `ansible.cfg` — Local Ansible configuration.
- `group_vars/all.yml` — **All customization lives here**: packages, plugins, extensions, system settings.
- `roles/`:
  - `homebrew` — Installs taps, formulae, and casks from flat lists in `group_vars/all.yml`; each package shown individually in output.
  - `dotfiles` — Initializes chezmoi from `dotfiles_repo`, syncs via `git` module, and applies dotfiles.
  - `fish` — Registers Fish in `/etc/shells`, sets as default shell, installs Fisher and plugins.
  - `system` — Applies macOS `defaults` for Dock, Finder, Safari, keyboard, screenshots, and Terminal font; sets computer name.
  - `vscode` — Installs extensions and symlinks config files from `~/.config/vscode`.
  - `tmux` — Installs tmux plugin manager (TPM) into `~/.config/tmux/plugins/tpm`.

---

## 🧪 Testing with Tart (Apple Silicon VM)

To test in a clean environment without affecting your host machine, use [Tart](https://tart.run/):

```bash
tart pull ghcr.io/cirruslabs/macos-tahoe:latest
tart clone ghcr.io/cirruslabs/macos-tahoe:latest test-vm
tart set test-vm --disk-size 100
tart run test-vm
# Then run ./bootstrap.sh inside the VM
# update wezterm for gpu support on tart by remove comment in ~/.config/wezterm/wezterm.lua
```

To reset and test again:

```bash
tart delete test-vm
tart clone ghcr.io/cirruslabs/macos-tahoe:latest test-vm
```

# Chezmoi Dotfiles Template

A template for managing dotfiles with [chezmoi](https://www.chezmoi.io/) featuring:

- **Fish shell** as default with tmux
- **mise** for runtime version management
- **Claude CLI** with bypass permissions mode
- **Git credentials** with age-encrypted secrets
- **URL-based git identity** (different email per host)
- **Auto-clone repositories** on setup
- **Parallel installation** for speed

## Quick Start

### 1. Generate age key

```bash
mkdir -p ~/.config/chezmoi
age-keygen -o ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

Save the public key (starts with `age1...`).

### 2. Configure this template

1. Update `.chezmoi.toml.tmpl` with your age public key
2. Update `dot_gitconfig-*` files with your name/email
3. Update `dot_gitconfig.tmpl` with your GitHub username
4. Update `run_once_install.sh` with your repos

### 3. Create encrypted secrets

```bash
cp secrets.toml.example secrets.toml
# Edit secrets.toml with your PATs
age -r "YOUR_PUBLIC_KEY" -o .chezmoidata.toml.age secrets.toml
rm secrets.toml
```

### 4. Commit and push

```bash
git add -A
git commit -m "Initial dotfiles setup"
git push
```

## Usage

### New machine setup

```bash
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)"

# Copy your age key to ~/.config/chezmoi/key.txt

# Apply dotfiles
chezmoi init https://github.com/YOUR_USERNAME/YOUR_REPO.git
chezmoi apply
```

### Update secrets

```bash
# Decrypt
age -d -i ~/.config/chezmoi/key.txt .chezmoidata.toml.age > secrets.toml

# Edit secrets.toml

# Re-encrypt
age -r "YOUR_PUBLIC_KEY" -o .chezmoidata.toml.age secrets.toml
rm secrets.toml
```

## Files

| File | Description |
|------|-------------|
| `.chezmoi.toml.tmpl` | Chezmoi config with age encryption |
| `run_once_install.sh` | One-time install script (packages, tools, repos) |
| `dot_gitconfig.tmpl` | Git config with encrypted credentials |
| `dot_gitconfig-*` | Per-host git identity (name/email) |
| `dot_tmux.conf` | Tmux config (mouse on) |
| `dot_claude.json` | Claude CLI config |
| `.chezmoidata.toml.age` | Encrypted secrets (you create this) |
| `secrets.toml.example` | Template for secrets |

## Customization

### Add a new git host

1. Create `dot_gitconfig-newhost` with name/email
2. Add `includeIf` section in `dot_gitconfig.tmpl`
3. Add credential helper in `dot_gitconfig.tmpl`
4. Add secrets to `secrets.toml.example` and your encrypted file

### Add packages

Edit `PACKAGES` array in `run_once_install.sh`.

### Add repos to auto-clone

Edit `REPOS` array in `run_once_install.sh`.

#!/bin/bash
# run_once_install.sh - runs once on first chezmoi apply

set -e
START_TIME=$(date +%s)

#
# CONFIGURATION - edit these as needed
#

PACKAGES=(fish tmux fzf ripgrep curl age git)

REPOS=(
    # Add your repos here, e.g.:
    # https://github.com/yourusername/your-repo.git
)

#
# INSTALLATION
#

# Helper: add line to file if not present
add_line() { grep -qF "$1" "$2" 2>/dev/null || echo "$1" >> "$2"; }

# Install packages, mise, and claude in parallel
{
    if command -v apt-get &>/dev/null; then
        sudo apt-get update && sudo apt-get install -y "${PACKAGES[@]}"
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm "${PACKAGES[@]}"
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y "${PACKAGES[@]}"
    fi
} &
curl -fsSL https://mise.run | sh &
curl -fsSL https://claude.ai/install.sh | bash &
wait

# Configure bash
add_line 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc
add_line 'export PATH="$HOME/.local/bin:$PATH"' ~/.profile
add_line 'eval "$(mise activate bash)"' ~/.bashrc
add_line 'eval "$(mise activate bash)"' ~/.profile
add_line "alias claude='claude --dangerously-skip-permissions'" ~/.bashrc

# Configure fish
mkdir -p ~/.config/fish
add_line 'fish_add_path ~/.local/bin' ~/.config/fish/config.fish
add_line 'mise activate fish | source' ~/.config/fish/config.fish
add_line "alias claude='claude --dangerously-skip-permissions'" ~/.config/fish/config.fish

# Set fish as default shell
FISH_PATH=$(command -v fish)
grep -qF "$FISH_PATH" /etc/shells || echo "$FISH_PATH" | sudo tee -a /etc/shells
[ "$SHELL" != "$FISH_PATH" ] && sudo chsh -s "$FISH_PATH" "$USER"

# Clone repos in parallel
for url in "${REPOS[@]}"; do
    dir="$HOME/projects/$(echo "$url" | sed 's|https://||;s|\.git$||' | tr '[:upper:]' '[:lower:]')"
    [ -d "$dir" ] || { mkdir -p "$(dirname "$dir")"; git clone "$url" "$dir" & }
done
wait

# Log timing
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
echo "$(date -Iseconds) - Install completed in ${DURATION}s" >> ~/.dotfiles-install.log

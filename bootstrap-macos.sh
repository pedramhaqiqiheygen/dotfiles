#!/bin/bash
set -e

echo "Setting up macOS dev environment..."

# Homebrew
if ! command -v brew &>/dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Core tools
echo "Installing core tools..."
brew install tmux fzf zoxide neovim git curl

# Nerd Font (required for tmux theme icons)
echo "Installing JetBrainsMono Nerd Font..."
brew install --cask font-jetbrains-mono-nerd-font

# Oh My Zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# Zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] || \
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] || \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

# TPM (tmux plugin manager)
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "Installing TPM..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Starship prompt
if ! command -v starship &>/dev/null; then
    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# NVM
if [[ ! -d "$HOME/.nvm" ]]; then
    echo "Installing NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

# Make dev scripts executable
chmod +x ~/.local/bin/dev ~/.local/bin/dev-status 2>/dev/null

echo ""
echo "Done! Next steps:"
echo "  1. Set iTerm font to 'JetBrainsMono Nerd Font' (Settings → Profiles → Text)"
echo "  2. Run 'chsh -s $(which zsh)' to set zsh as default shell"
echo "  3. Open a new terminal — tmux command center starts automatically"

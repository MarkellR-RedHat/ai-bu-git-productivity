#!/usr/bin/env bash
# ai-bu-git-productivity/install.sh
# Sets up aliases, gitconfig extras, and the pre-commit hook.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$SCRIPT_DIR/aliases.sh\""

echo "=== ai-bu-git-productivity installer ==="
echo ""

# ─── 1. Source aliases into shell config ──────────────────────────────────────
detect_shell_config() {
  if [ -n "${ZSH_VERSION:-}" ] || [ "$SHELL" = "$(command -v zsh)" ]; then
    echo "$HOME/.zshrc"
  else
    echo "$HOME/.bashrc"
  fi
}

SHELL_CONFIG=$(detect_shell_config)

echo "[1/3] Shell aliases"
if grep -qF "$SOURCE_LINE" "$SHELL_CONFIG" 2>/dev/null; then
  echo "  Already present in $SHELL_CONFIG. Skipping."
else
  printf "  Add aliases to %s? [Y/n] " "$SHELL_CONFIG"
  read -r answer
  if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
    echo "" >> "$SHELL_CONFIG"
    echo "# ai-bu-git-productivity aliases" >> "$SHELL_CONFIG"
    echo "$SOURCE_LINE" >> "$SHELL_CONFIG"
    echo "  Added. Run 'source $SHELL_CONFIG' or open a new terminal to activate."
  else
    echo "  Skipped. You can manually add this line to your shell config:"
    echo "    $SOURCE_LINE"
  fi
fi
echo ""

# ─── 2. Install gitconfig extras ─────────────────────────────────────────────
GITCONFIG_PATH="$SCRIPT_DIR/gitconfig-extras"

echo "[2/3] Git config extras"
printf "  Include gitconfig-extras in your global git config? [y/N] "
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  # Check if already included
  existing=$(git config --global --get-all include.path 2>/dev/null || true)
  if echo "$existing" | grep -qF "$GITCONFIG_PATH"; then
    echo "  Already included. Skipping."
  else
    git config --global --add include.path "$GITCONFIG_PATH"
    echo "  Added include.path to global git config."
  fi
else
  echo "  Skipped. You can manually run:"
  echo "    git config --global include.path \"$GITCONFIG_PATH\""
fi
echo ""

# ─── 3. Install pre-commit hook ──────────────────────────────────────────────
echo "[3/3] Pre-commit hook"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  GIT_DIR=$(git rev-parse --git-dir)
  HOOK_DEST="$GIT_DIR/hooks/pre-commit"
  if [ -f "$HOOK_DEST" ]; then
    echo "  A pre-commit hook already exists at $HOOK_DEST."
    printf "  Overwrite it? [y/N] "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      cp "$SCRIPT_DIR/hooks/pre-commit-check" "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      echo "  Installed."
    else
      echo "  Skipped."
    fi
  else
    printf "  Install the pre-commit hook to this repo? [Y/n] "
    read -r answer
    if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
      mkdir -p "$GIT_DIR/hooks"
      cp "$SCRIPT_DIR/hooks/pre-commit-check" "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      echo "  Installed to $HOOK_DEST."
    else
      echo "  Skipped."
    fi
  fi
else
  echo "  Not inside a git repo. Skipping hook installation."
  echo "  To install manually, copy hooks/pre-commit-check to your repo's .git/hooks/pre-commit."
fi
echo ""

echo "=== Setup complete ==="
echo "Open a new terminal or run 'source $SHELL_CONFIG' to start using the aliases."

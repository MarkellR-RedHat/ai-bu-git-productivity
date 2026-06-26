#!/usr/bin/env bash
# ai-bu-git-productivity/install.sh
# Sets up aliases, gitconfig extras, and hooks.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$SCRIPT_DIR/aliases.sh\""

# ─── Color helpers ───────────────────────────────────────────────────────────
if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  CYAN=$(tput setaf 6)
  RED=$(tput setaf 1)
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
else
  GREEN="" YELLOW="" CYAN="" RED="" BOLD="" RESET=""
fi

info()  { echo "${CYAN}>>>${RESET} $*"; }
ok()    { echo "${GREEN} OK${RESET} $*"; }
warn()  { echo "${YELLOW}  !${RESET} $*"; }
err()   { echo "${RED}ERR${RESET} $*"; }

echo ""
echo "${BOLD}========================================${RESET}"
echo "${BOLD}  ai-bu-git-productivity installer${RESET}"
echo "${BOLD}========================================${RESET}"
echo ""

echo "${BOLD}This installer will set up:${RESET}"
echo "  - Shell aliases and functions (glog, gweek, gdash, gcontrib, ...)"
echo "  - Git config extras (histogram diffs, auto-stash, rerere, ...)"
echo "  - Pre-commit hook (blocks secrets, large files, conflict markers)"
echo "  - Commit-msg hook (warns on short or lowercase messages)"
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

info "${BOLD}[1/4] Shell aliases${RESET}"
if grep -qF "$SOURCE_LINE" "$SHELL_CONFIG" 2>/dev/null; then
  ok "Already present in $SHELL_CONFIG. Skipping."
else
  # Check for conflicts with existing aliases
  ALIAS_NAMES="glog gweek gstale gclean gpr greview gblame-who gdiff-stat gundo gwip gunwip gcontrib gfind gchanged gtoday grebase-main gopen gdash"
  conflicts=""
  for name in $ALIAS_NAMES; do
    if command -v "$name" &>/dev/null 2>&1; then
      conflicts="$conflicts $name"
    elif alias "$name" &>/dev/null 2>&1; then
      conflicts="$conflicts $name"
    fi
  done
  if [ -n "$conflicts" ]; then
    warn "Detected existing commands that will be shadowed:${YELLOW}$conflicts${RESET}"
    warn "These will be overridden when you source aliases.sh."
    echo ""
  fi

  printf "  Add aliases to %s? [Y/n] " "$SHELL_CONFIG"
  read -r answer
  if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
    echo "" >> "$SHELL_CONFIG"
    echo "# ai-bu-git-productivity aliases" >> "$SHELL_CONFIG"
    echo "$SOURCE_LINE" >> "$SHELL_CONFIG"
    ok "Added to $SHELL_CONFIG."
    info "Run 'source $SHELL_CONFIG' or open a new terminal to activate."
  else
    warn "Skipped. You can manually add this line to your shell config:"
    echo "    $SOURCE_LINE"
  fi
fi
echo ""

# ─── 2. Install gitconfig extras ─────────────────────────────────────────────
GITCONFIG_PATH="$SCRIPT_DIR/gitconfig-extras"

info "${BOLD}[2/4] Git config extras${RESET}"
printf "  Include gitconfig-extras in your global git config? [y/N] "
read -r answer
if [[ "$answer" =~ ^[Yy]$ ]]; then
  existing=$(git config --global --get-all include.path 2>/dev/null || true)
  if echo "$existing" | grep -qF "$GITCONFIG_PATH"; then
    ok "Already included. Skipping."
  else
    git config --global --add include.path "$GITCONFIG_PATH"
    ok "Added include.path to global git config."
  fi
else
  warn "Skipped. You can manually run:"
  echo "    git config --global include.path \"$GITCONFIG_PATH\""
fi
echo ""

# ─── 3. Install pre-commit hook ──────────────────────────────────────────────
info "${BOLD}[3/4] Pre-commit hook${RESET}"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  GIT_DIR=$(git rev-parse --git-dir)
  HOOK_DEST="$GIT_DIR/hooks/pre-commit"
  if [ -f "$HOOK_DEST" ]; then
    warn "A pre-commit hook already exists at $HOOK_DEST."
    printf "  Overwrite it? [y/N] "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      cp "$SCRIPT_DIR/hooks/pre-commit-check" "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      ok "Installed (replaced existing hook)."
    else
      warn "Skipped."
    fi
  else
    printf "  Install the pre-commit hook to this repo? [Y/n] "
    read -r answer
    if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
      mkdir -p "$GIT_DIR/hooks"
      cp "$SCRIPT_DIR/hooks/pre-commit-check" "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      ok "Installed to $HOOK_DEST."
    else
      warn "Skipped."
    fi
  fi
else
  warn "Not inside a git repo. Skipping hook installation."
  echo "  To install manually, copy hooks/pre-commit-check to your repo's .git/hooks/pre-commit."
fi
echo ""

# ─── 4. Install commit-msg hook ──────────────────────────────────────────────
info "${BOLD}[4/4] Commit-msg hook${RESET}"
if git rev-parse --is-inside-work-tree &>/dev/null; then
  GIT_DIR=$(git rev-parse --git-dir)
  HOOK_DEST="$GIT_DIR/hooks/commit-msg"
  if [ -f "$HOOK_DEST" ]; then
    warn "A commit-msg hook already exists at $HOOK_DEST."
    printf "  Overwrite it? [y/N] "
    read -r answer
    if [[ "$answer" =~ ^[Yy]$ ]]; then
      cp "$SCRIPT_DIR/hooks/commit-msg" "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      ok "Installed (replaced existing hook)."
    else
      warn "Skipped."
    fi
  else
    printf "  Install the commit-msg hook to this repo? [Y/n] "
    read -r answer
    if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
      mkdir -p "$GIT_DIR/hooks"
      cp "$SCRIPT_DIR/hooks/commit-msg" "$HOOK_DEST"
      chmod +x "$HOOK_DEST"
      ok "Installed to $HOOK_DEST."
    else
      warn "Skipped."
    fi
  fi
else
  warn "Not inside a git repo. Skipping hook installation."
  echo "  To install manually, copy hooks/commit-msg to your repo's .git/hooks/commit-msg."
fi
echo ""

echo "${BOLD}========================================${RESET}"
echo "${GREEN}  Setup complete${RESET}"
echo "${BOLD}========================================${RESET}"
echo ""
echo "Open a new terminal or run '${CYAN}source $SHELL_CONFIG${RESET}' to start using the aliases."
echo ""

#!/usr/bin/env bash
# ai-bu-git-productivity/install.sh
# Interactive installer for the git productivity toolkit.
# Detects your shell, previews what will be installed, backs up existing
# configs, and lets you pick components.
#
# Usage:
#   bash install.sh           # interactive install
#   bash install.sh --preview # show what would be installed without changing anything

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$SCRIPT_DIR/aliases.sh\""
BACKUP_DIR="$HOME/.git-productivity-backups/$(date +%Y%m%d-%H%M%S)"
PREVIEW_ONLY=false

if [[ "${1:-}" == "--preview" ]]; then
  PREVIEW_ONLY=true
fi

# =============================================================================
# Color helpers
# =============================================================================
if [ -t 1 ] && command -v tput &>/dev/null && [ "$(tput colors 2>/dev/null || echo 0)" -ge 8 ]; then
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  CYAN=$(tput setaf 6)
  RED=$(tput setaf 1)
  BOLD=$(tput bold)
  DIM=$(tput dim 2>/dev/null || echo "")
  RESET=$(tput sgr0)
else
  GREEN="" YELLOW="" CYAN="" RED="" BOLD="" DIM="" RESET=""
fi

info()    { echo "${CYAN}>>>${RESET} $*"; }
ok()      { echo "${GREEN} OK${RESET} $*"; }
warn()    { echo "${YELLOW}  !${RESET} $*"; }
err()     { echo "${RED}ERR${RESET} $*"; }
section() { echo ""; echo "${BOLD}${CYAN}=== $* ===${RESET}"; echo ""; }

# =============================================================================
# Shell detection
# =============================================================================
detect_shell() {
  local shell_name
  shell_name=$(basename "${SHELL:-bash}")
  echo "$shell_name"
}

detect_shell_config() {
  local shell_name
  shell_name=$(detect_shell)
  case "$shell_name" in
    zsh)
      echo "$HOME/.zshrc"
      ;;
    fish)
      echo "$HOME/.config/fish/config.fish"
      ;;
    *)
      if [ -f "$HOME/.bashrc" ]; then
        echo "$HOME/.bashrc"
      elif [ -f "$HOME/.bash_profile" ]; then
        echo "$HOME/.bash_profile"
      else
        echo "$HOME/.bashrc"
      fi
      ;;
  esac
}

DETECTED_SHELL=$(detect_shell)
SHELL_CONFIG=$(detect_shell_config)

# =============================================================================
# Backup function
# =============================================================================
backup_file() {
  local file="$1"
  if [ -f "$file" ]; then
    mkdir -p "$BACKUP_DIR"
    cp "$file" "$BACKUP_DIR/$(basename "$file")"
    ok "Backed up $file to $BACKUP_DIR/"
  fi
}

# =============================================================================
# Banner
# =============================================================================
echo ""
echo "${BOLD}============================================${RESET}"
echo "${BOLD}  Git Productivity Toolkit${RESET}"
echo "${BOLD}============================================${RESET}"
echo ""
echo "  You type 'git status' ~30 times a day."
echo "  That is 300 keystrokes. ${CYAN}gs${RESET} does the same in 2."
echo ""
echo "  Detected shell:  ${CYAN}$DETECTED_SHELL${RESET}"
echo "  Shell config:    ${CYAN}$SHELL_CONFIG${RESET}"
echo ""

if [ "$DETECTED_SHELL" = "fish" ]; then
  echo "${YELLOW}NOTE: Fish shell detected. The aliases use bash/zsh syntax."
  echo "They will be sourced via a bash compatibility layer (bass plugin)."
  echo "Some features may not work perfectly. Bash or zsh is recommended.${RESET}"
  echo ""
fi

if [ "$PREVIEW_ONLY" = true ]; then
  echo "${YELLOW}PREVIEW MODE: showing what would be installed. No changes will be made.${RESET}"
  echo ""
fi

# =============================================================================
# Preview: Top 10 aliases
# =============================================================================
section "What You Get: Top 10 Time Savers"

echo "  ${CYAN}gs${RESET}              ${DIM}git status with branch + ahead/behind${RESET}"
echo "                    ${DIM}Saves: 8 keystrokes x 30/day = 240/day${RESET}"
echo ""
echo "  ${CYAN}gc \"msg\"${RESET}         ${DIM}git add -A && git commit -m \"msg\"${RESET}"
echo "                    ${DIM}Saves: 25 keystrokes x 15/day = 375/day${RESET}"
echo ""
echo "  ${CYAN}gpush${RESET}            ${DIM}git push -u origin <current-branch>${RESET}"
echo "                    ${DIM}Saves: 30+ keystrokes (no more --set-upstream dance)${RESET}"
echo ""
echo "  ${CYAN}glog${RESET}             ${DIM}pretty log with graph, colors, relative dates${RESET}"
echo "                    ${DIM}Saves: 40+ keystrokes (no more --format flags)${RESET}"
echo ""
echo "  ${CYAN}gco${RESET}              ${DIM}checkout branch (fzf interactive picker if available)${RESET}"
echo "  ${CYAN}gcb <name>${RESET}       ${DIM}git checkout -b <name>${RESET}"
echo "  ${CYAN}gwip / gunwip${RESET}    ${DIM}quick WIP commit / undo it${RESET}"
echo "  ${CYAN}grebase-main${RESET}     ${DIM}fetch + rebase onto main (auto-detects main vs master)${RESET}"
echo "  ${CYAN}pr-create${RESET}        ${DIM}create PR, auto-fill title from branch name${RESET}"
echo "  ${CYAN}gdash${RESET}            ${DIM}full repo dashboard in one command${RESET}"
echo ""
echo "  ${DIM}...plus 35+ more aliases. See aliases.sh for the full list.${RESET}"

if [ "$PREVIEW_ONLY" = true ]; then
  section "Git Config Extras (gitconfig-extras)"
  echo "  diff.algorithm = histogram       ${DIM}cleaner diffs${RESET}"
  echo "  merge.conflictstyle = zdiff3     ${DIM}easier conflict resolution${RESET}"
  echo "  rebase.autoStash = true          ${DIM}auto-stash before rebase${RESET}"
  echo "  push.autoSetupRemote = true      ${DIM}no more --set-upstream${RESET}"
  echo "  rerere.enabled = true            ${DIM}remembers conflict resolutions${RESET}"
  echo "  core.fsmonitor = true            ${DIM}faster status on large repos${RESET}"

  section "Hooks"
  echo "  ${CYAN}pre-commit${RESET}   Blocks secrets, large files, debug statements, conflict markers"
  echo "  ${CYAN}commit-msg${RESET}   Suggests conventional commit format (does not block)"
  echo "  ${CYAN}pre-push${RESET}     Warns about uncommitted changes, blocks WIP to main"

  echo ""
  echo "${BOLD}Run without --preview to install.${RESET}"
  echo ""
  exit 0
fi

# =============================================================================
# Install prompt
# =============================================================================
echo ""
printf "Install all components? [Y/n] "
read -r install_all
INSTALL_ALL=false
if [[ "${install_all:-Y}" =~ ^[Yy]$ ]]; then
  INSTALL_ALL=true
fi

# =============================================================================
# 1. Shell aliases
# =============================================================================
section "Shell Aliases and Functions"

INSTALL_ALIASES=false
if [ "$INSTALL_ALL" = true ]; then
  INSTALL_ALIASES=true
else
  printf "Install shell aliases? [Y/n] "
  read -r answer
  if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
    INSTALL_ALIASES=true
  fi
fi

if [ "$INSTALL_ALIASES" = true ]; then
  if grep -qF "$SOURCE_LINE" "$SHELL_CONFIG" 2>/dev/null; then
    ok "Already present in $SHELL_CONFIG. Skipping."
  else
    # Check for conflicts with existing commands
    ALIAS_NAMES="gs glog glog1 gtoday gweek gc gwip gunwip gundo gstash gco gcb gpush gdash gclean grebase-main gopen pr-create pr-draft pr-ready pr-cleanup pr-stack greview gwho gwhen gfind gfind-code gdiff-stat gcontrib gchanged gstale gleaderboard gteam gcp greset-hard gclean-files pr-checkout pr-diff"
    conflicts=""
    for name in $ALIAS_NAMES; do
      if command -v "$name" &>/dev/null 2>&1; then
        conflicts="$conflicts $name"
      fi
    done
    if [ -n "$conflicts" ]; then
      warn "Existing commands that will be shadowed:${YELLOW}$conflicts${RESET}"
      echo ""
    fi

    backup_file "$SHELL_CONFIG"

    if [ "$DETECTED_SHELL" = "fish" ]; then
      FISH_SOURCE="bass source \"$SCRIPT_DIR/aliases.sh\""
      echo "" >> "$SHELL_CONFIG"
      echo "# ai-bu-git-productivity aliases (requires bass: https://github.com/edc/bass)" >> "$SHELL_CONFIG"
      echo "$FISH_SOURCE" >> "$SHELL_CONFIG"
      ok "Added to $SHELL_CONFIG (using bass for bash compatibility)."
      warn "Make sure you have the 'bass' fish plugin installed."
    else
      echo "" >> "$SHELL_CONFIG"
      echo "# ai-bu-git-productivity aliases" >> "$SHELL_CONFIG"
      echo "$SOURCE_LINE" >> "$SHELL_CONFIG"
      ok "Added to $SHELL_CONFIG."
    fi
  fi
else
  warn "Skipped aliases. To add manually:"
  echo "    $SOURCE_LINE"
fi

# =============================================================================
# 2. Git config extras
# =============================================================================
section "Git Config Extras"

GITCONFIG_PATH="$SCRIPT_DIR/gitconfig-extras"
INSTALL_GITCONFIG=false

if [ "$INSTALL_ALL" = true ]; then
  INSTALL_GITCONFIG=true
else
  printf "Include gitconfig-extras in your global git config? [Y/n] "
  read -r answer
  if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
    INSTALL_GITCONFIG=true
  fi
fi

if [ "$INSTALL_GITCONFIG" = true ]; then
  existing=$(git config --global --get-all include.path 2>/dev/null || true)
  if echo "$existing" | grep -qF "$GITCONFIG_PATH"; then
    ok "Already included in global git config. Skipping."
  else
    backup_file "$HOME/.gitconfig"
    git config --global --add include.path "$GITCONFIG_PATH"
    ok "Added include.path to global git config."
  fi
else
  warn "Skipped git config. To add manually:"
  echo "    git config --global include.path \"$GITCONFIG_PATH\""
fi

# =============================================================================
# 3-5. Hooks
# =============================================================================

install_hook() {
  local hook_source="$1"
  local hook_name="$2"
  local hook_desc="$3"

  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    warn "Not inside a git repo. Skipping $hook_name hook."
    echo "  To install later: cp $hook_source .git/hooks/$hook_name && chmod +x .git/hooks/$hook_name"
    return
  fi

  local git_dir
  git_dir=$(git rev-parse --git-dir)
  local hook_dest="$git_dir/hooks/$hook_name"

  local should_install=false
  if [ "$INSTALL_ALL" = true ]; then
    should_install=true
  else
    echo "  $hook_desc"
    echo ""
    printf "  Install the $hook_name hook? [Y/n] "
    read -r answer
    if [[ "${answer:-Y}" =~ ^[Yy]$ ]]; then
      should_install=true
    fi
  fi

  if [ "$should_install" = true ]; then
    if [ -f "$hook_dest" ]; then
      warn "A $hook_name hook already exists at $hook_dest."
      backup_file "$hook_dest"
      printf "  Replace it? [y/N] "
      read -r answer
      if [[ "$answer" =~ ^[Yy]$ ]]; then
        cp "$hook_source" "$hook_dest"
        chmod +x "$hook_dest"
        ok "Installed $hook_name hook (replaced existing, backup saved)."
      else
        warn "Skipped. Existing hook preserved."
      fi
    else
      mkdir -p "$git_dir/hooks"
      cp "$hook_source" "$hook_dest"
      chmod +x "$hook_dest"
      ok "Installed $hook_name hook."
    fi
  else
    warn "Skipped $hook_name hook."
  fi
}

section "Pre-commit Hook"
install_hook \
  "$SCRIPT_DIR/hooks/pre-commit-check" \
  "pre-commit" \
  "Blocks secrets, large files, debug statements, and conflict markers."

section "Commit-msg Hook"
install_hook \
  "$SCRIPT_DIR/hooks/commit-msg" \
  "commit-msg" \
  "Suggests conventional commit format (does not block your commit)."

section "Pre-push Hook"
install_hook \
  "$SCRIPT_DIR/hooks/pre-push" \
  "pre-push" \
  "Warns about uncommitted changes, blocks WIP commits to main/master."

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "${BOLD}============================================${RESET}"
echo "${GREEN}  Installation complete${RESET}"
echo "${BOLD}============================================${RESET}"
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo "  Backups saved to: ${CYAN}$BACKUP_DIR${RESET}"
  echo ""
fi

echo "  Get started:"
echo "    1. Open a new terminal or run '${CYAN}source $SHELL_CONFIG${RESET}'"
echo "    2. Type '${CYAN}gs${RESET}' instead of 'git status'"
echo "    3. Type '${CYAN}glog${RESET}' instead of 'git log --oneline --graph --decorate --all'"
echo "    4. Type '${CYAN}gdash${RESET}' for a full repo overview"
echo ""
echo "  Read ${CYAN}workflows.md${RESET} for copy-paste commands for every scenario."
echo ""

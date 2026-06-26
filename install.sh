#!/usr/bin/env bash
# ai-bu-git-productivity/install.sh
# Interactive installer for the git productivity toolkit.
# Detects your shell, previews what will be installed, lets you pick components,
# and backs up existing configs before making any changes.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$SCRIPT_DIR/aliases.sh\""
BACKUP_DIR="$HOME/.git-productivity-backups/$(date +%Y%m%d-%H%M%S)"

# =============================================================================
# Color helpers (graceful fallback for non-color terminals)
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
      # bash and everything else
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
echo "${BOLD}  ai-bu-git-productivity installer${RESET}"
echo "${BOLD}============================================${RESET}"
echo ""
echo "  Detected shell:  ${CYAN}$DETECTED_SHELL${RESET}"
echo "  Shell config:    ${CYAN}$SHELL_CONFIG${RESET}"
echo ""

if [ "$DETECTED_SHELL" = "fish" ]; then
  echo "${YELLOW}NOTE: Fish shell detected. The aliases in this toolkit use bash/zsh"
  echo "syntax. They will be sourced via a bash compatibility layer, but some"
  echo "features may not work perfectly. Consider using bash or zsh for best results.${RESET}"
  echo ""
fi

echo "${BOLD}This toolkit includes:${RESET}"
echo ""
echo "  ${GREEN}1.${RESET} Shell aliases and functions"
echo "     ${DIM}40+ shortcuts for daily git work, PR workflow, investigation, cleanup${RESET}"
echo ""
echo "  ${GREEN}2.${RESET} Git config extras"
echo "     ${DIM}Performance tuning, better diffs, auto-stash, rerere, color scheme${RESET}"
echo ""
echo "  ${GREEN}3.${RESET} Pre-commit hook"
echo "     ${DIM}Blocks secrets, large files, debug statements, conflict markers${RESET}"
echo ""
echo "  ${GREEN}4.${RESET} Commit-msg hook"
echo "     ${DIM}Enforces conventional commit format (feat/fix/docs/etc.)${RESET}"
echo ""
echo "  ${GREEN}5.${RESET} Pre-push hook"
echo "     ${DIM}Warns about uncommitted changes, blocks WIP commits to main${RESET}"
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
  echo "Preview of what you get:"
  echo ""
  echo "  ${CYAN}gs${RESET}             git status with branch info and ahead/behind count"
  echo "  ${CYAN}glog${RESET}           beautiful one-line log with colors and graph"
  echo "  ${CYAN}gwip / gunwip${RESET}  quick WIP commit / undo it"
  echo "  ${CYAN}gc \"msg\"${RESET}       stage all + commit in one shot"
  echo "  ${CYAN}gcb branch${RESET}     create and switch to a new branch"
  echo "  ${CYAN}gpush${RESET}          push + set upstream in one command"
  echo "  ${CYAN}grebase-main${RESET}   fetch + rebase onto main (auto-detects main vs master)"
  echo "  ${CYAN}pr-create${RESET}      create PR with title auto-filled from branch name"
  echo "  ${CYAN}pr-cleanup${RESET}     delete merged branches locally and remotely"
  echo "  ${CYAN}gdash${RESET}          full repo dashboard in one command"
  echo "  ${DIM}  ...and 30+ more. See aliases.sh for the full list.${RESET}"
  echo ""
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
    # Check for conflicts with existing aliases
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
      # Fish needs a different source syntax
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
  echo "Preview of settings:"
  echo ""
  echo "  ${CYAN}diff.algorithm = histogram${RESET}       cleaner, faster diffs"
  echo "  ${CYAN}merge.conflictstyle = zdiff3${RESET}     easier conflict resolution"
  echo "  ${CYAN}rebase.autoStash = true${RESET}          auto-stash before rebase"
  echo "  ${CYAN}push.autoSetupRemote = true${RESET}      no more --set-upstream"
  echo "  ${CYAN}rerere.enabled = true${RESET}            remembers conflict resolutions"
  echo "  ${CYAN}core.fsmonitor = true${RESET}            faster status on large repos"
  echo "  ${DIM}  ...and more. See gitconfig-extras for the full list.${RESET}"
  echo ""
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
    # Back up existing gitconfig
    backup_file "$HOME/.gitconfig"
    git config --global --add include.path "$GITCONFIG_PATH"
    ok "Added include.path to global git config."
  fi
else
  warn "Skipped git config. To add manually:"
  echo "    git config --global include.path \"$GITCONFIG_PATH\""
fi

# =============================================================================
# 3. Pre-commit hook
# =============================================================================
section "Pre-commit Hook"

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

install_hook \
  "$SCRIPT_DIR/hooks/pre-commit-check" \
  "pre-commit" \
  "Blocks secrets, large files, debug statements, and conflict markers before commit."

# =============================================================================
# 4. Commit-msg hook
# =============================================================================
section "Commit-msg Hook"

install_hook \
  "$SCRIPT_DIR/hooks/commit-msg" \
  "commit-msg" \
  "Enforces conventional commit format (feat/fix/docs/etc.) and message quality."

# =============================================================================
# 5. Pre-push hook
# =============================================================================
section "Pre-push Hook"

install_hook \
  "$SCRIPT_DIR/hooks/pre-push" \
  "pre-push" \
  "Warns about uncommitted changes and blocks WIP commits to main/master."

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

echo "  Next steps:"
echo "    1. Open a new terminal or run '${CYAN}source $SHELL_CONFIG${RESET}'"
echo "    2. Try '${CYAN}gdash${RESET}' for a repo overview"
echo "    3. Try '${CYAN}gs${RESET}' instead of 'git status'"
echo "    4. Read ${CYAN}workflows.md${RESET} for complete workflow guides"
echo ""

#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────
# Git Productivity Toolkit -- installer
#
# Detects your shell, backs up existing configs, installs aliases,
# git config extras, and optional hooks. Every step asks before
# changing anything.
#
# Usage:
#   bash install.sh           # interactive install
#   bash install.sh --preview # dry run, shows what would change
#   bash install.sh --help    # print usage and exit
# ─────────────────────────────────────────────────────────────────────

set -euo pipefail

cleanup_on_error() {
  echo ""
  echo "${RED:-}ERROR: Install failed at line $1.${RESET:-}"
  echo "Your original configs were not modified (or were backed up first)."
  echo "Fix the issue and re-run: bash install.sh"
  echo ""
}
trap 'cleanup_on_error $LINENO' ERR

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_LINE="source \"$SCRIPT_DIR/aliases.sh\""
BACKUP_DIR="$HOME/.git-productivity-backups/$(date +%Y%m%d-%H%M%S)"
PREVIEW_ONLY=false

case "${1:-}" in
  --preview) PREVIEW_ONLY=true ;;
  --help|-h)
    echo "Usage: bash install.sh [--preview | --help]"
    echo ""
    echo "  --preview   Dry run. Shows what would be installed without changing anything."
    echo "  --help      Print this message and exit."
    exit 0
    ;;
  "")  ;; # no argument, proceed normally
  *)
    echo "Unknown option: $1"
    echo "Usage: bash install.sh [--preview | --help]"
    exit 1
    ;;
esac

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
# Prerequisite checks
# =============================================================================
if ! command -v git &>/dev/null; then
  echo "ERROR: git is not installed. Install git first, then re-run this script."
  exit 1
fi

if [ ! -f "$SCRIPT_DIR/aliases.sh" ]; then
  echo "ERROR: aliases.sh not found in $SCRIPT_DIR."
  echo "Make sure you are running install.sh from the toolkit directory."
  exit 1
fi

# =============================================================================
# Fish shell compatibility check
# =============================================================================
check_fish_compatibility() {
  if [ "$DETECTED_SHELL" != "fish" ]; then
    return 0
  fi

  # Check if bass is installed (required for bash-syntax aliases in fish)
  if command -v fish &>/dev/null; then
    if ! fish -c 'type -q bass' 2>/dev/null; then
      warn "Fish detected but 'bass' plugin is not installed."
      warn "Without bass, the bash-syntax aliases will not work in fish."
      echo ""
      echo "  Install bass first:"
      echo "    fisher install edc/bass"
      echo ""
      printf "Continue anyway? [y/N] "
      read -r answer
      if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Install bass, then re-run this script."
        exit 1
      fi
    fi
  fi
}

# =============================================================================
# Default branch detection
# =============================================================================
detect_default_branch() {
  # If we are inside a git repo, figure out the default branch name.
  # This matters because hooks reference main/master and we need to
  # verify our assumptions match the repo.
  if ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    echo "main"
    return
  fi

  local branch
  branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||')
  if [ -n "$branch" ]; then
    echo "$branch"
    return
  fi

  if git rev-parse --verify origin/main &>/dev/null; then
    echo "main"
  elif git rev-parse --verify origin/master &>/dev/null; then
    echo "master"
  elif git rev-parse --verify main &>/dev/null; then
    echo "main"
  elif git rev-parse --verify master &>/dev/null; then
    echo "master"
  else
    echo "main"
  fi
}

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
echo "${BOLD}┌──────────────────────────────────────────┐${RESET}"
echo "${BOLD}│       Git Productivity Toolkit           │${RESET}"
echo "${BOLD}│       40+ aliases, 3 hooks, done.        │${RESET}"
echo "${BOLD}└──────────────────────────────────────────┘${RESET}"
echo ""
echo "  Shell:   ${CYAN}$DETECTED_SHELL${RESET}"
echo "  Config:  ${CYAN}$SHELL_CONFIG${RESET}"
echo "  Source:  ${CYAN}$SCRIPT_DIR${RESET}"
echo ""

if [ "$DETECTED_SHELL" = "fish" ]; then
  echo "${YELLOW}NOTE: Fish detected. Aliases use bash/zsh syntax and need the bass plugin."
  echo "Bash or zsh recommended.${RESET}"
  echo ""
  check_fish_compatibility
fi

if [ "$PREVIEW_ONLY" = true ]; then
  echo "${YELLOW}PREVIEW MODE: showing what would be installed. No changes will be made.${RESET}"
  echo ""
fi

# =============================================================================
# Preview: what will be installed
# =============================================================================
section "What Will Be Installed"

echo "  ${BOLD}1. Shell aliases${RESET} (source line added to $SHELL_CONFIG)"
echo ""
echo "     ${CYAN}gs${RESET}              ${DIM}status with branch + ahead/behind${RESET}"
echo "     ${CYAN}gc \"msg\"${RESET}         ${DIM}stage all + commit${RESET}"
echo "     ${CYAN}gpush${RESET}            ${DIM}push + auto set upstream${RESET}"
echo "     ${CYAN}glog${RESET}             ${DIM}graph log with colors and dates${RESET}"
echo "     ${CYAN}gco${RESET}              ${DIM}checkout (fzf picker if no arg)${RESET}"
echo "     ${CYAN}gcb <name>${RESET}       ${DIM}create + switch branch${RESET}"
echo "     ${CYAN}gwip / gunwip${RESET}    ${DIM}WIP commit / undo it${RESET}"
echo "     ${CYAN}grebase-main${RESET}     ${DIM}fetch + rebase onto main/master${RESET}"
echo "     ${CYAN}pr-create${RESET}        ${DIM}create PR from branch name${RESET}"
echo "     ${CYAN}gdash${RESET}            ${DIM}full repo dashboard${RESET}"
echo "     ${DIM}...plus 35+ more. See aliases.sh for the full list.${RESET}"
echo ""
echo "  ${BOLD}2. Git config extras${RESET} (include.path in global gitconfig)"
echo ""
echo "     diff.algorithm = histogram       ${DIM}cleaner diffs${RESET}"
echo "     merge.conflictstyle = zdiff3     ${DIM}easier conflict resolution${RESET}"
echo "     rebase.autoStash = true          ${DIM}auto-stash before rebase${RESET}"
echo "     push.autoSetupRemote = true      ${DIM}no more --set-upstream${RESET}"
echo "     rerere.enabled = true            ${DIM}remembers conflict resolutions${RESET}"
echo "     core.fsmonitor = true            ${DIM}faster status on large repos${RESET}"
echo ""
echo "  ${BOLD}3. Hooks${RESET} (installed to .git/hooks/ in current repo)"
echo ""
echo "     ${CYAN}pre-commit${RESET}   Blocks secrets, large files, debug statements"
echo "     ${CYAN}commit-msg${RESET}   Suggests conventional commit format (never blocks)"
echo "     ${CYAN}pre-push${RESET}     Warns about uncommitted changes, blocks WIP to main"

if [ "$PREVIEW_ONLY" = true ]; then
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
    # Check for conflicts with existing commands (binaries, scripts, other aliases)
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

    # Check for conflicting shell aliases already defined in the config file
    existing_aliases=""
    for name in $ALIAS_NAMES; do
      if grep -qE "^(alias ${name}=|${name}\(\))" "$SHELL_CONFIG" 2>/dev/null; then
        existing_aliases="$existing_aliases $name"
      fi
    done
    if [ -n "$existing_aliases" ]; then
      warn "Shell aliases or functions already defined in $SHELL_CONFIG:${YELLOW}$existing_aliases${RESET}"
      warn "The toolkit's versions will load AFTER your existing ones and take priority."
      echo "  To keep your originals, comment out the source line after install."
      echo ""
    fi

    # Check for git aliases in gitconfig that overlap with our shell aliases
    git_alias_conflicts=""
    for name in st amend last recent ds who uncommit; do
      if git config --global --get "alias.$name" &>/dev/null; then
        git_alias_conflicts="$git_alias_conflicts git-$name"
      fi
    done
    if [ -n "$git_alias_conflicts" ]; then
      info "Your global gitconfig already defines these git aliases:${CYAN}$git_alias_conflicts${RESET}"
      echo "  The gitconfig-extras file may override them. Backups are saved."
      echo ""
    fi

    backup_file "$SHELL_CONFIG"

    # Make sure the config file exists and is writable
    touch "$SHELL_CONFIG" 2>/dev/null || {
      err "Cannot write to $SHELL_CONFIG. Check file permissions."
      exit 1
    }

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
      # Check whether the existing hook is ours (from a previous install)
      if grep -qF "ai-bu-git-productivity" "$hook_dest" 2>/dev/null; then
        info "Existing $hook_name hook is from a previous install. Updating."
        cp "$hook_source" "$hook_dest"
        chmod +x "$hook_dest"
        ok "Updated $hook_name hook."
      else
        warn "A $hook_name hook already exists at $hook_dest."
        warn "It does not appear to be from this toolkit."
        backup_file "$hook_dest"
        printf "  Replace it? [y/N] "
        read -r answer
        if [[ "$answer" =~ ^[Yy]$ ]]; then
          cp "$hook_source" "$hook_dest"
          chmod +x "$hook_dest"
          ok "Installed $hook_name hook (replaced existing, backup saved)."
        else
          warn "Skipped. Existing hook preserved."
          echo "  To chain hooks, look into core.hooksPath or a hook manager like husky/lefthook."
        fi
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
  "Blocks secrets, large files, debug statements, conflict markers."

section "Commit-msg Hook"
install_hook \
  "$SCRIPT_DIR/hooks/commit-msg" \
  "commit-msg" \
  "Suggests conventional commit format. Never blocks."

section "Pre-push Hook"
install_hook \
  "$SCRIPT_DIR/hooks/pre-push" \
  "pre-push" \
  "Warns about uncommitted changes, blocks WIP commits to main/master."

# =============================================================================
# Default branch check
# =============================================================================
section "Default Branch"

DEFAULT_BRANCH=$(detect_default_branch)
if [ "$DEFAULT_BRANCH" != "main" ]; then
  warn "This repo's default branch is '${YELLOW}$DEFAULT_BRANCH${RESET}', not 'main'."
  echo "  All toolkit aliases (grebase-main, gwip, pr-cleanup, etc.) auto-detect"
  echo "  main vs master. If your default branch uses a different name (e.g."
  echo "  'develop', 'trunk'), the _git_default_branch helper in aliases.sh"
  echo "  will fall back to 'main'. You may want to set your remote HEAD:"
  echo ""
  echo "    git remote set-head origin $DEFAULT_BRANCH"
  echo ""
else
  ok "Default branch is 'main'. All aliases will work out of the box."
fi

# =============================================================================
# core.hooksPath check
# =============================================================================
HOOKS_PATH=$(git config --get core.hooksPath 2>/dev/null || true)
if [ -n "$HOOKS_PATH" ]; then
  warn "core.hooksPath is set to: ${YELLOW}$HOOKS_PATH${RESET}"
  echo "  Git will use that directory for hooks, NOT .git/hooks/."
  echo "  If the hooks we just installed are not firing, either:"
  echo "    1. Copy them into $HOOKS_PATH"
  echo "    2. Or unset core.hooksPath: git config --unset core.hooksPath"
  echo ""
fi

# =============================================================================
# Summary
# =============================================================================
echo ""
echo "${BOLD}============================================${RESET}"
echo "${GREEN}  Done.${RESET}"
echo "${BOLD}============================================${RESET}"
echo ""

if [ -d "$BACKUP_DIR" ]; then
  echo "  Backups: ${CYAN}$BACKUP_DIR${RESET}"
  echo ""
fi

echo "  Next steps:"
echo "    1. Run '${CYAN}source $SHELL_CONFIG${RESET}' or open a new terminal"
echo "    2. Try ${CYAN}gs${RESET}, ${CYAN}glog${RESET}, ${CYAN}gdash${RESET}"
echo "    3. See ${CYAN}workflows.md${RESET} for copy-paste commands"
echo ""

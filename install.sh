#!/usr/bin/env bash
# install.sh — Install skills and agents directly to ~/.claude/
# Usage: ./install.sh [all|rpi|dw]
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SUBSET="${1:-all}"

DW_SKILLS=(deep-work dw-01-research-questions dw-02-research dw-03-design-discussion dw-04-outline dw-05-plan dw-06-implement)
RPI_SKILLS=(rpi-research rpi-plan rpi-implement)
AGENTS=(codebase-analyzer.md codebase-locator.md codebase-pattern-finder.md)
SETUP_CONSUMERS=(dw-01-research-questions dw-02-research dw-03-design-discussion dw-04-outline dw-05-plan dw-06-implement rpi-research rpi-plan rpi-implement)

install_skills() {
    local -a skill_list=("$@")
    for skill in "${skill_list[@]}"; do
        local src="$REPO_ROOT/skills/$skill"
        local dest="$CLAUDE_DIR/skills/$skill"
        if [ -d "$src" ]; then
            mkdir -p "$dest"
            cp -R "$src"/* "$dest/"

            # Co-locate setup.sh if this skill needs it
            for consumer in "${SETUP_CONSUMERS[@]}"; do
                if [ "$skill" = "$consumer" ]; then
                    cp "$REPO_ROOT/skills/shared/setup.sh" "$dest/setup.sh"
                    break
                fi
            done
        fi
    done
}

install_agents() {
    mkdir -p "$CLAUDE_DIR/agents"
    for agent in "${AGENTS[@]}"; do
        cp "$REPO_ROOT/agents/$agent" "$CLAUDE_DIR/agents/$agent"
    done
}

case "$SUBSET" in
    all)
        install_skills "${DW_SKILLS[@]}"
        install_skills "${RPI_SKILLS[@]}"
        install_agents
        echo "Installed all skills and agents to $CLAUDE_DIR/"
        ;;
    dw)
        install_skills "${DW_SKILLS[@]}"
        install_agents
        echo "Installed DW skills and agents to $CLAUDE_DIR/"
        ;;
    rpi)
        install_skills "${RPI_SKILLS[@]}"
        install_agents
        echo "Installed RPI skills and agents to $CLAUDE_DIR/"
        ;;
    *)
        echo "Usage: $0 [all|rpi|dw]"
        exit 1
        ;;
esac

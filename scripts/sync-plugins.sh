#!/usr/bin/env bash
# sync-plugins.sh — Generate marketplace plugin directories from source-of-truth files.
# Run manually or via the pre-commit hook.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

DW_SKILLS=(deep-work dw-01-research-questions dw-02-research dw-03-design-discussion dw-04-outline dw-05-plan dw-05b-plan-review dw-06-implement)
RPI_SKILLS=(rpi-research rpi-plan rpi-implement)
AGENTS=(codebase-analyzer.md codebase-locator.md codebase-pattern-finder.md)

# Skills that reference setup.sh (all except deep-work, which is docs-only)
SETUP_CONSUMERS=(dw-01-research-questions dw-02-research dw-03-design-discussion dw-04-outline dw-05-plan dw-05b-plan-review dw-06-implement rpi-research rpi-plan rpi-implement)

sync_plugin() {
    local plugin_name="$1"
    shift
    local -a skill_list=("$@")

    local plugin_dir="$REPO_ROOT/plugins/$plugin_name"

    # Clean previous generated content (preserve .claude-plugin/)
    rm -rf "$plugin_dir/skills" "$plugin_dir/agents"
    mkdir -p "$plugin_dir/skills" "$plugin_dir/agents"

    # Copy skills
    for skill in "${skill_list[@]}"; do
        local src="$REPO_ROOT/skills/$skill"
        local dest="$plugin_dir/skills/$skill"
        if [ -d "$src" ]; then
            cp -R "$src" "$dest"
        fi
    done

    # Co-locate setup.sh in every skill directory that needs it
    for skill in "${skill_list[@]}"; do
        local dest="$plugin_dir/skills/$skill"
        if [ -d "$dest" ]; then
            for consumer in "${SETUP_CONSUMERS[@]}"; do
                if [ "$skill" = "$consumer" ]; then
                    cp "$REPO_ROOT/skills/shared/setup.sh" "$dest/setup.sh"
                    break
                fi
            done
        fi
    done

    # Copy agents
    for agent in "${AGENTS[@]}"; do
        cp "$REPO_ROOT/agents/$agent" "$plugin_dir/agents/$agent"
    done

    echo "Synced plugin: $plugin_name (${#skill_list[@]} skills, ${#AGENTS[@]} agents)"
}

sync_plugin "dw" "${DW_SKILLS[@]}"
sync_plugin "rpi" "${RPI_SKILLS[@]}"

echo "Plugin sync complete."

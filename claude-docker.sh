#!/bin/bash

# Script to run Claude Code in Docker
# 

set -e

IMAGE_NAME="coopernurse/claude-docker"
REMOTE_HOME="/home/claude"

# Check if image exists
if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
    echo "Error: Docker image '$IMAGE_NAME' not found."
    echo "Please build the image first with: docker-compose build"
    exit 1
fi

# Check if ~/.claude directory exists
if [ ! -d "$HOME/.claude" ]; then
    echo "Warning: ~/.claude directory does not exist. Creating it..."
    mkdir -p "$HOME/.claude"
fi

# Determine which settings file to use
SETTINGS_ARG=""
if [ "$1" = "mini" ]; then
    SETTINGS_ARG="--settings $REMOTE_HOME/.claude/settings-minimax.json"
fi

CMD="claude --dangerously-skip-permissions $SETTINGS_ARG"
if [ "$1" = "bash" ]; then
    CMD="/bin/bash"
fi
if [ "$1" = "opencode" ]; then
    CMD="opencode"
fi

# Run the container
echo "Starting Claude Code..."
echo "Workspace: $(pwd)"
echo ""

docker run -it --rm \
  -v "$(pwd):/workspace" \
  -v claude-data:/home/claude \
  -v "$HOME/.claude:/other-claude" \
  -v "$HOME/.local/share/opencode:$REMOTE_HOME/.local/share/opencode" \
  -v "$HOME/.local/state/opencode:$REMOTE_HOME/.local/state/opencode" \
  -w /workspace \
  "$IMAGE_NAME" \
  $CMD

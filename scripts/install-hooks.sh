#!/bin/sh
#
# Install Git hooks for this project
#

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

echo "📦 Installing Git hooks..."

# Copy pre-push hook
cp "$SCRIPT_DIR/pre-push" "$HOOKS_DIR/pre-push"
chmod +x "$HOOKS_DIR/pre-push"

echo "✅ pre-push hook installed!"
echo ""
echo "🎉 Git hooks installation complete!"

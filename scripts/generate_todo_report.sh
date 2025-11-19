#!/bin/bash
# Script to generate TODO_REPORT.md from TODO comments in the codebase

set -e

# Output file
OUTPUT_FILE="TODO_REPORT.md"

# Get the script directory and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$REPO_ROOT"

# Start writing the report
cat > "$OUTPUT_FILE" << 'EOF'
# TODO Inventory

This file records current TODO markers across the repository.
Update by running `make update-todos` from the repo root.

EOF

# Search for TODO comments and append to the file
# Using grep for compatibility (ripgrep may not be installed)
grep -rn --include="*.c" --include="*.cpp" --include="*.h" --include="*.py" "TODO" src/ 2>/dev/null | sort >> "$OUTPUT_FILE" || true

echo "TODO report generated successfully at $OUTPUT_FILE"
echo "Found $(grep -c ":" "$OUTPUT_FILE" 2>/dev/null || echo 0) TODO items"

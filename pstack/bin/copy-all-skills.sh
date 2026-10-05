#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <target-directory>" >&2
  echo "Copy skill directories from this repo into <target-directory>." >&2
  echo "Child directories under skills/ whose names start with '_' are skipped." >&2
  echo "Example: $0 ~/.pi/agent/skills" >&2
}

if [[ $# -lt 1 || -z "${1:-}" ]]; then
  echo "Error: target directory is required." >&2
  usage
  exit 1
fi

TARGET="${1/#\~/$HOME}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Error: skills directory not found: $SKILLS_DIR" >&2
  exit 1
fi

if [[ -e "$TARGET" && ! -d "$TARGET" ]]; then
  echo "Error: target exists and is not a directory: $TARGET" >&2
  exit 1
fi

mkdir -p "$TARGET"
TARGET="$(cd "$TARGET" && pwd)"

copied=0
skipped=0

for skill in "$SKILLS_DIR"/*; do
  [[ -d "$skill" ]] || continue
  name="$(basename "$skill")"

  if [[ "$name" == _* ]]; then
    echo "Skipping $name"
    skipped=$((skipped + 1))
    continue
  fi

  dest="$TARGET/$name"
  rm -rf "$dest"
  cp -R "$skill" "$dest"
  echo "Copied $name -> $dest"
  copied=$((copied + 1))
done

echo "Done. Copied $copied skill(s), skipped $skipped."

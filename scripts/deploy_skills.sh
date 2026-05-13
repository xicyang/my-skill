#!/bin/bash

# Deploy skills to a target project by symlinking into .claude/skills/
# Usage: deploy_skills.sh <target-project-dir> [--category <cat>] [--skill <name>]
# Examples:
#   deploy_skills.sh .                          # deploy all skills
#   deploy_skills.sh . --category engineering   # deploy only engineering skills
#   deploy_skills.sh . --skill paper-reader      # deploy a single skill

SKILLS_SOURCE_DIR="/data/xcyang19/claude-skills-repo"

if [ -z "$1" ] || [ "$1" = "--category" ] || [ "$1" = "--skill" ]; then
  echo "Usage: $0 <target-project-dir> [--category <category>] [--skill <skill-name>]"
  echo ""
  echo "Categories: engineering, guide, personal"
  echo ""
  echo "Examples:"
  echo "  $0 .                          # deploy all skills"
  echo "  $0 . --category engineering   # deploy only engineering skills"
  echo "  $0 . --skill paper-reader      # deploy a single skill"
  exit 1
fi

TARGET_PROJECT_DIR=$(realpath "$1")
TARGET_SKILLS_DIR="$TARGET_PROJECT_DIR/.claude/skills"
mkdir -p "$TARGET_SKILLS_DIR"

# Parse optional flags
CATEGORY=""
SKILL_NAME=""
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --category) CATEGORY="$2"; shift 2 ;;
    --skill)    SKILL_NAME="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

deploy_skill() {
  local src_path="$1"
  local skill_name=$(basename "$src_path")
  local target_link="$TARGET_SKILLS_DIR/$skill_name"

  if [ -L "$target_link" ]; then
    rm "$target_link"
  elif [ -d "$target_link" ]; then
    echo "Warning: physical directory '$skill_name' already exists, skipping."
    return
  fi

  ln -s "$src_path" "$target_link"
  echo "Linked: $skill_name -> $target_link"
}

cd "$SKILLS_SOURCE_DIR" || exit 1

if [ -n "$SKILL_NAME" ]; then
  # Deploy a single skill — search across all categories
  found=""
  for category_dir in skills/*/; do
    candidate="${category_dir}${SKILL_NAME}"
    if [ -d "$candidate" ]; then
      found="$candidate"
      break
    fi
  done
  if [ -z "$found" ]; then
    echo "Error: skill '$SKILL_NAME' not found in any category."
    exit 1
  fi
  deploy_skill "$SKILLS_SOURCE_DIR/$found"
elif [ -n "$CATEGORY" ]; then
  # Deploy all skills in a category
  category_path="skills/$CATEGORY"
  if [ ! -d "$category_path" ]; then
    echo "Error: category '$CATEGORY' not found."
    echo "Available: $(ls skills/)"
    exit 1
  fi
  for skill_dir in "$category_path"/*/; do
    [ ! -d "$skill_dir" ] && continue
    deploy_skill "$SKILLS_SOURCE_DIR/$skill_dir"
  done
else
  # Deploy all skills across all categories
  for category_dir in skills/*/; do
    [ ! -d "$category_dir" ] && continue
    for skill_dir in "$category_dir"*/; do
      [ ! -d "$skill_dir" ] && continue
      deploy_skill "$SKILLS_SOURCE_DIR/$skill_dir"
    done
  done
fi

echo "Done."
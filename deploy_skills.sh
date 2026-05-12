#!/bin/bash

# 检查是否提供了目标项目路径
if [ -z "$1" ]; then
  echo "❌ 错误: 请提供目标项目目录。"
  echo "用法: /data/xcyang19/claude-skills-repo/deploy_skills.sh ."
  exit 1
fi

TARGET_PROJECT_DIR=$(realpath "$1")

# 这里直接锁死你的绝对路径，超级安全
SKILLS_SOURCE_DIR="/data/xcyang19/claude-skills-repo"

# 确保目标项目的 .claude/skills 目录存在
TARGET_SKILLS_DIR="$TARGET_PROJECT_DIR/.claude/skills"
mkdir -p "$TARGET_SKILLS_DIR"

# 进入技能源目录进行遍历
cd "$SKILLS_SOURCE_DIR" || exit

for skill_dir in */ ; do
    # 忽略非目录文件和隐藏文件
    if [ ! -d "$skill_dir" ]; then continue; fi

    skill_name=${skill_dir%/}
    target_link="$TARGET_SKILLS_DIR/$skill_name"
    
    if [ -L "$target_link" ]; then
        rm "$target_link"
    elif [ -d "$target_link" ]; then
        echo "⚠️ 警告: 物理文件夹 '$skill_name' 已存在，跳过。"
        continue
    fi
    
    ln -s "$SKILLS_SOURCE_DIR/$skill_name" "$target_link"
    echo "✅ 成功链接: $skill_name -> $target_link"
done

echo "🎉 所有技能已从 /data/xcyang19 部署完毕！"
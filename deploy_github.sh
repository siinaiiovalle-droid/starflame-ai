#!/bin/bash
# ============================================================
# 星焰智能 · 一键部署到 GitHub Pages（永久公网地址）
# ============================================================
#
# 前置条件：你需要在 github.com 有一个免费账号
# 如果还没有，花 2 分钟注册：https://github.com/signup
#
# 使用方法：在终端里运行 bash deploy_github.sh
# ============================================================

set -e

REPO="starflame-ai"
DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🌐 星焰智能 · GitHub Pages 部署"
echo "================================"
echo ""

# ── Step 1: Check for gh CLI ──
if ! command -v gh &> /dev/null; then
    echo "正在安装 GitHub CLI..."
    if command -v brew &> /dev/null; then
        brew install gh
    else
        echo "请先安装 GitHub CLI:"
        echo "  https://cli.github.com"
        exit 1
    fi
fi

# ── Step 2: Login ──
echo "正在打开浏览器进行 GitHub 登录（只需一次）..."
gh auth login --web --hostname github.com --git-protocol https

# ── Step 3: Create repo & push ──
cd "$DIR"
if ! gh repo view "$REPO" &>/dev/null 2>&1; then
    echo "正在创建仓库 $REPO ..."
    gh repo create "$REPO" --public --source=. --remote=origin --push
else
    echo "仓库已存在，正在推送..."
    git remote add origin "https://github.com/$(gh api user --jq .login)/$REPO.git" 2>/dev/null || true
    git push -u origin main --force
fi

# ── Step 4: Enable Pages ──
echo "正在启用 GitHub Pages..."
gh api "repos/$(gh api user --jq .login)/$REPO/pages" -X POST -F "source[branch]=main" -F "source[path]=/" --silent 2>/dev/null || echo "Pages 可能已启用"

# ── Step 5: URL ──
USERNAME=$(gh api user --jq .login)
echo ""
echo "================================"
echo "✅ 部署完成！"
echo ""
echo "🔗 永久公网地址："
echo "   https://$USERNAME.github.io/$REPO"
echo ""
echo "（首次部署可能需要 1-2 分钟后生效）"
echo "================================"

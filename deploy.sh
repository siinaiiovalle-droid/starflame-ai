#!/bin/bash
# ═══════════════════════════════════════════════
# 星焰智能 网站公网部署脚本
# 在你的 Mac 终端里运行: bash deploy.sh
# ═══════════════════════════════════════════════

DIR="$(cd "$(dirname "$0")" && pwd)"

echo "🌐 星焰智能网站部署"
echo "========================="
echo ""

# Check for surge
if ! command -v surge &> /dev/null; then
    echo "正在安装 Surge..."
    npm install -g surge
fi

# Generate unique domain
DOMAIN="starflame-ai-$(date +%s).surge.sh"

echo "正在部署到 $DOMAIN ..."
cd "$DIR"

# Deploy
surge . "$DOMAIN" 2>&1

echo ""
echo "========================="
echo "✅ 部署完成！"
echo "🔗 公网地址: https://$DOMAIN"
echo "========================="

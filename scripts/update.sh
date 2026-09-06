#!/bin/bash
#
# update.sh
# New-API 一键更新脚本
#
# 使用方法：
#   bash /opt/newapi/scripts/update.sh
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

cd /opt/newapi

echo "======================================"
echo "  New-API 更新脚本"
echo "======================================"

# 1. 备份当前数据
warn "更新前先备份..."
bash scripts/backup.sh

# 2. 拉取最新镜像
info "拉取最新镜像..."
docker compose pull new-api

# 3. 重启服务
info "重启 New-API..."
docker compose up -d new-api

# 4. 等待启动
echo "等待服务启动..."
sleep 15

# 5. 验证
if docker compose ps | grep -q "new-api.*running"; then
    info "✅ New-API 更新成功"
    docker compose logs new-api --tail 20
else
    error "❌ 更新失败，请检查日志："
    docker compose logs new-api --tail 50
    exit 1
fi

echo ""
info "更新完成"

#!/bin/bash
#
# deploy.sh
# New-API 一键部署脚本（Docker Compose）
#
# 使用方法（在 VPS 上执行）：
#   1. 上传 configs/docker-compose.yml 到 /opt/newapi/
#   2. 上传本脚本到 /opt/newapi/scripts/deploy.sh
#   3. bash scripts/deploy.sh
#

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }
step() { echo -e "${BLUE}[STEP]${NC} $1"; }

if [ "$EUID" -ne 0 ]; then
    error "请使用 root 用户运行此脚本"
    exit 1
fi

echo "======================================"
echo "  New-API 一键部署脚本"
echo "======================================"

# Step 1: 检查 Docker
step "Step 1/7: 检查 Docker 环境..."
if ! command -v docker &> /dev/null; then
    warn "Docker 未安装，开始安装..."
    curl -fsSL https://get.docker.com | bash
    info "Docker 安装完成 ✅"
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    error "Docker Compose 不可用，请先安装 Docker"
    exit 1
fi
info "Docker 环境正常 ✅"

# Step 2: 创建目录结构
step "Step 2/7: 创建目录结构..."
mkdir -p /opt/newapi/{data,mysql,redis,backups,scripts}
cd /opt/newapi
info "目录创建完成 ✅"

# Step 3: 生成 .env 文件
step "Step 3/7: 生成环境变量..."
if [ ! -f .env ]; then
    SESSION_SECRET=$(openssl rand -base64 32 | tr -d '\n')
    CRYPTO_SECRET=$(openssl rand -base64 32 | tr -d '\n')

    cat > .env <<EOF
# New-API 环境变量
SESSION_SECRET=${SESSION_SECRET}
CRYPTO_SECRET=${CRYPTO_SECRET}
TZ=Asia/Shanghai

# MySQL 密码（生产环境请修改）
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 16 | tr -d '\n')
MYSQL_DATABASE=new-api

# New-API 端口（默认 3000）
NEWAPI_PORT=3000
EOF

    chmod 600 .env
    info ".env 文件已生成 ✅"
else
    warn ".env 已存在，跳过"
fi

# Step 4: 检查 docker-compose.yml
step "Step 4/7: 检查 docker-compose.yml..."
if [ ! -f docker-compose.yml ]; then
    error "docker-compose.yml 不存在，请先上传到 /opt/newapi/"
    exit 1
fi
info "docker-compose.yml 已就位 ✅"

# Step 5: 拉取镜像
step "Step 5/7: 拉取 Docker 镜像..."
docker compose pull
info "镜像拉取完成 ✅"

# Step 6: 启动服务
step "Step 6/7: 启动服务..."
docker compose up -d

# 等待服务启动
echo ""
warn "等待服务启动（约 30 秒）..."
sleep 30

# Step 7: 验证
step "Step 7/7: 验证部署..."

if docker compose ps | grep -q "new-api.*running"; then
    info "✅ New-API 容器运行正常"
else
    error "New-API 容器未运行，请查看日志："
    docker compose logs new-api --tail 50
    exit 1
fi

if docker compose ps | grep -q "mysql.*running"; then
    info "✅ MySQL 容器运行正常"
else
    error "MySQL 容器未运行"
    docker compose logs mysql --tail 50
    exit 1
fi

# 获取 VPS IP
VPS_IP=$(curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')

echo ""
echo "======================================"
echo -e "${GREEN}  ✅ 部署完成！${NC}"
echo "======================================"
echo ""
echo "访问地址：http://${VPS_IP}:3000"
echo ""
echo "默认账号："
echo "  用户名：root"
echo "  密码：123456"
echo ""
echo -e "${YELLOW}⚠️  首次登录后立即修改默认密码！${NC}"
echo ""
echo "下一步建议："
echo "  1. 登录后台修改 root 密码"
echo "  2. 关闭公开注册"
echo "  3. 配置 HTTPS（参考 docs/02-部署指南.md）"
echo "  4. 接入上游 API（参考 docs/03-上游接入.md）"
echo ""
echo "查看日志："
echo "  cd /opt/newapi && docker compose logs -f new-api"
echo ""

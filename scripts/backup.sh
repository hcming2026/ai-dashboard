#!/bin/bash
#
# backup.sh
# New-API 数据自动备份脚本
#
# 使用方法：
#   1. 配置下方 KEEP_DAYS 等参数
#   2. 添加到 crontab：0 3 * * * /opt/newapi/scripts/backup.sh
#

set -e

# 配置
BACKUP_DIR="/opt/newapi/backups"
KEEP_DAYS=30
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# 创建备份目录
mkdir -p "$BACKUP_DIR/mysql"
mkdir -p "$BACKUP_DIR/config"

cd /opt/newapi

# 1. 备份 MySQL 数据库
echo "[$(date)] 备份 MySQL..."
if docker compose ps | grep -q "mysql.*running"; then
    docker compose exec -T mysql sh -c 'exec mysqldump -uroot -p"$MYSQL_ROOT_PASSWORD" new-api' > "$BACKUP_DIR/mysql/new-api-${TIMESTAMP}.sql" 2>/dev/null

    if [ -s "$BACKUP_DIR/mysql/new-api-${TIMESTAMP}.sql" ]; then
        gzip "$BACKUP_DIR/mysql/new-api-${TIMESTAMP}.sql"
        echo "[$(date)] ✅ MySQL 备份成功"
    else
        echo "[$(date)] ❌ MySQL 备份失败"
        rm -f "$BACKUP_DIR/mysql/new-api-${TIMESTAMP}.sql"
    fi
else
    echo "[$(date)] ❌ MySQL 容器未运行"
fi

# 2. 备份配置文件
echo "[$(date)] 备份配置..."
tar czf "$BACKUP_DIR/config/config-${TIMESTAMP}.tar.gz" \
    docker-compose.yml .env 2>/dev/null || echo "[$(date)] 配置文件不存在"

# 3. 清理旧备份
echo "[$(date)] 清理 $KEEP_DAYS 天前的旧备份..."
find "$BACKUP_DIR/mysql" -name "*.sql.gz" -mtime +$KEEP_DAYS -delete
find "$BACKUP_DIR/config" -name "*.tar.gz" -mtime +$KEEP_DAYS -delete

# 4. 显示当前备份列表
echo ""
echo "当前备份列表："
echo "  MySQL 备份："
ls -lh "$BACKUP_DIR/mysql/" 2>/dev/null | tail -n +2 | head -10
echo "  配置备份："
ls -lh "$BACKUP_DIR/config/" 2>/dev/null | tail -n +2 | head -5

echo ""
echo "[$(date)] 备份任务完成"

# 5. 可选：上传到远程存储
# 取消注释并配置：

# 上传到 S3（需要 aws cli）
# aws s3 sync "$BACKUP_DIR" s3://your-bucket/newapi-backups/

# 上传到另一台服务器
# rsync -avz --delete "$BACKUP_DIR/" user@backup-server:/backups/newapi/

# 上传到 Google Drive（需要 rclone）
# rclone sync "$BACKUP_DIR" gdrive:newapi-backups/

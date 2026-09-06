# New-API 一键部署脚本
# 用途：自动化部署 + 安全加固
# 依赖：configs/docker-compose.yml

bash /opt/newapi/scripts/deploy.sh

# 部署后必做：
# 1. 登录 http://你的IP:3000 → 用户名 root / 密码 123456
# 2. 修改默认密码
# 3. 关闭公开注册
# 4. 配置 HTTPS（参见 docs/02-部署指南.md 第四章）
# 5. 接入上游（参见 docs/03-上游接入.md）
# 6. 客户端指向 New-API（参见 docs/04-客户端配置.md）
```

## 📊 数据流架构

```
你的所有 AI 工具（ChatBox / LobeChat / Dify / Python SDK / Cursor）
    │
    │  base_url: https://api.你的域名.com/v1
    │  api_key:  New-API 生成的 token
    │
    ▼
┌──────────────────┐
│   Nginx (443)    │ ← HTTPS 证书
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│   New-API (3000) │ ← 用户管理 + 用量统计 + 路由
└────────┬─────────┘
         │
         ├──→ OpenAI
         ├──→ Claude (Anthropic)
         ├──→ DeepSeek
         ├──→ 通义千问 (Qwen)
         ├──→ 智谱 GLM
         └──→ Gemini
```

## 🔐 安全特性

- ✅ HTTPS 加密（Let's Encrypt 免费证书）
- ✅ 默认账号强制修改
- ✅ 支持 2FA
- ✅ Token 与上游 Key 隔离
- ✅ 用户额度 + 限速
- ✅ 自动备份（cron）
- ✅ Docker 隔离

## 🛠️ 常用命令速查

```bash
# SSH 连 VPS
ssh root@你的VPS_IP

# 进入项目目录
cd /opt/newapi

# 查看服务状态
docker compose ps

# 查看 New-API 日志
docker compose logs -f new-api

# 重启服务
docker compose restart

# 停止服务
docker compose down

# 更新 New-API
bash scripts/update.sh

# 手动备份
bash scripts/backup.sh
```

## 🌟 进阶玩法

- 多用户配额管理
- 接入 MCP（Model Context Protocol）
- 自建 Prometheus + Grafana 监控
- 多 VPS 高可用部署

## 📝 维护建议

| 频率 | 任务 |
|------|------|
| 每天 | 无（自动运行）|
| 每周 | 查看用量趋势 |
| 每月 | 更新镜像 + 检查备份 |
| 每季 | 升级到最新版（看 GitHub release）|

## 📞 遇到问题？

1. 查看对应文档（docs/ 目录）
2. 搜索 GitHub Issues
3. 查看 Docker 日志：`docker compose logs`
4. 检查防火墙、域名解析

## 📄 许可证

本项目配置文件采用 MIT 许可证。
**New-API 本身采用 AGPL-3.0 许可证**，个人自用无影响。

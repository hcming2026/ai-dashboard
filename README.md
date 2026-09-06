# AI Dashboard (New-API)

> 🧠 一站式 AI 模型聚合网关 + 用量统计 Dashboard
> 让你的所有 AI 工具统一指向一个地址，所有 token 消耗一目了然

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![New-API](https://img.shields.io/badge/New--API-v1.0.0rc25-green.svg)](https://github.com/QuantumNous/new-api)
[![Docker](https://img.shields.io/badge/docker-compose-blue.svg)](docker-compose.yml)
[![Maintenance](https://img.shields.io/badge/maintained-active-brightgreen.svg)]()
[![Privacy](https://img.shields.io/badge/visibility-private-lightgrey.svg)]()

---

## ✨ 为什么需要这个项目？

| 痛点 | 这个项目的解决方案 |
|------|------------------|
| 用了 5 个 AI 平台，要切 5 个网站查用量 | **一个 Dashboard 看所有平台** |
| 每个平台独立 Key，泄露一个 = 全泄露 | **Token 与上游 Key 隔离**，泄露 Token 可单独禁用 |
| 某平台挂了要等恢复 | **多渠道自动 failover** |
| 多人共用 Key 没法统计谁花了多少 | **每个 Token 独立统计** |
| 想换平台要改代码 | **只改 base_url**，不改代码 |

---

## 🎯 核心特性

- 🔄 **多模型聚合**：OpenAI · Claude · DeepSeek · 通义千问 · 智谱 GLM · Gemini，一套 API 全打通
- 📊 **用量统计 Dashboard**：按渠道/模型/用户/时间维度统计 token 与花费
- 🛡️ **自动故障转移**：主渠道挂了自动切备用
- 🔐 **安全加固**：HTTPS · 2FA · Token 隔离 · 限速 · 配额
- 🚀 **一键部署**：Docker Compose 起，5 分钟跑通
- 💾 **自动备份**：MySQL + 配置每日备份，可同步到云端
- 👥 **多用户管理**：每个用户独立 Token + 额度
- 🌐 **多客户端兼容**：ChatBox · LobeChat · Dify · Cursor · Python · Node.js · Claude Code

---

## 🏗️ 架构图

```
                    ┌────────────────────────────┐
                    │   你的所有 AI 工具          │
                    │  ChatBox / LobeChat / Dify │
                    │  Cursor / Python / Claude │
                    └─────────────┬──────────────┘
                                  │
                                  │ base_url: https://api.你的域名.com/v1
                                  │ api_key:  New-API token
                                  │
                                  ▼
                    ┌────────────────────────────┐
                    │   Nginx :443 (HTTPS)       │ ← Let's Encrypt 证书
                    └─────────────┬──────────────┘
                                  │
                                  ▼
                    ┌────────────────────────────┐
                    │   New-API :3000            │
                    │   ┌──────────────────┐     │
                    │   │ 用户管理         │     │
                    │   │ Token 管理       │     │
                    │   │ 用量统计         │     │
                    │   │ 渠道路由         │     │
                    │   │ 多 Key 轮询      │     │
                    │   └──────────────────┘     │
                    └─────────────┬──────────────┘
                                  │
            ┌──────────┬──────────┼──────────┬──────────┬──────────┐
            ▼          ▼          ▼          ▼          ▼          ▼
        ┌───────┐ ┌───────┐ ┌────────┐ ┌───────┐ ┌───────┐ ┌───────┐
        │OpenAI │ │Claude │ │DeepSeek│ │ Qwen  │ │  GLM  │ │Gemini │
        └───────┘ └───────┘ └────────┘ └───────┘ └───────┘ └───────┘
```

---

## 🚀 快速开始（5 分钟）

### 前置要求

- ✅ 一台 VPS（推荐 Ubuntu 22.04，1C1G 起步）
- ✅ 一个域名（如 `example.xyz`，¥7/年）
- ✅ Docker + Docker Compose 已安装

### 一键部署

```bash
# 1. SSH 登录 VPS
ssh root@你的VPS_IP

# 2. 创建项目目录
mkdir -p /opt/newapi && cd /opt/newapi

# 3. 上传本仓库的 configs/docker-compose.yml 到该目录

# 4. 一键部署（自动生成 .env + 拉镜像 + 启动 + 验证）
curl -fsSL https://raw.githubusercontent.com/hcming2026/ai-dashboard/main/scripts/deploy.sh | bash

# 5. 浏览器访问后台
# http://你的VPS_IP:3000
# 默认账号：root / 123456（首次登录立即修改！）
```

### 部署后必做的 6 件事

- [ ] 修改默认密码
- [ ] 关闭公开注册（系统设置 → 用户注册）
- [ ] 配置 HTTPS（Nginx + certbot，见 `docs/02-部署指南.md`）
- [ ] 接入至少 1 个上游渠道（推荐先接 DeepSeek，见 `docs/03-上游接入.md`）
- [ ] 创建第一个 Token（令牌管理）
- [ ] 配置自动备份 cron（`docs/05-维护与扩展.md`）

---

## 📚 文档索引

| 文档 | 内容 | 何时读 |
|------|------|--------|
| [docs/01-方案对比.md](docs/01-方案对比.md) | New-API vs One-API vs LiteLLM 选型分析 | 决定方案时 |
| [docs/02-部署指南.md](docs/02-部署指南.md) | Docker Compose 完整部署 + HTTPS 配置 | 第一次部署 |
| [docs/03-上游接入.md](docs/03-上游接入.md) | OpenAI / Claude / DeepSeek / Qwen / GLM 接入步骤 | 配置 AI 平台时 |
| [docs/04-客户端配置.md](docs/04-客户端配置.md) | 让你的工具指向 New-API（ChatBox / LobeChat / Cursor 等） | 日常使用 |
| [docs/05-维护与扩展.md](docs/05-维护与扩展.md) | 日常维护 + 异常处理 + 进阶玩法 | 长期运维 |

---

## 🌐 支持的 AI 平台

| 平台 | 模型 | 推荐场景 | 价格 |
|------|------|---------|------|
| **DeepSeek** | deepseek-chat / deepseek-reasoner | 💰 日常主力（最便宜）| ¥1-2/百万 token |
| **OpenAI** | gpt-4o / gpt-4o-mini / o1 | 🎯 复杂推理 | $2.5-15/百万 token |
| **Claude** | claude-sonnet-4.5 / claude-opus | 📝 长文本 + 代码 | $3-15/百万 token |
| **通义千问** | qwen-plus / qwen-max / qwen-long | 🌏 中文场景 | ¥4-60/百万 token |
| **智谱 GLM** | glm-4-plus / glm-4-flash | 🌏 中文 + 免费额度 | ¥1-50/百万 token |
| **Gemini** | gemini-2.0-flash / gemini-1.5-pro | 🆓 免费额度 | 免费 / $0.075 |

**推荐组合**（个人研究用，月预算 ¥100-150）：
- 主力：`deepseek-chat`（便宜快）
- 备选：`gpt-4o-mini`（强能力）
- 长文：`qwen-long` 或 `gemini-1.5-pro`
- 免费备用：`gemini-2.0-flash`

---

## 📁 项目结构

```
ai-dashboard/
├── README.md                  ← 你在这里
├── .gitignore                 ← 保护敏感信息
├── docs/                      ← 完整文档
│   ├── 01-方案对比.md
│   ├── 02-部署指南.md
│   ├── 03-上游接入.md
│   ├── 04-客户端配置.md
│   └── 05-维护与扩展.md
├── scripts/                   ← 部署与运维脚本
│   ├── deploy.sh              ← 一键部署
│   ├── backup.sh              ← 自动备份
│   └── update.sh              ← 一键更新
└── configs/                   ← 配置文件
    ├── docker-compose.yml     ← New-API + MySQL + Redis
    └── nginx.conf             ← Nginx 反代（含 SSL）
```

---

## 🛠️ 常用命令速查

```bash
# SSH 连 VPS
ssh root@你的VPS_IP

# 进入项目目录
cd /opt/newapi

# 查看所有容器状态
docker compose ps

# 实时查看 New-API 日志
docker compose logs -f new-api

# 重启服务（不停机）
docker compose restart

# 完全停止
docker compose down

# 一键更新到最新版
bash scripts/update.sh

# 手动备份
bash scripts/backup.sh

# 查看自动备份文件
ls -lh /opt/newapi/backups/mysql/
```

---

## 🔐 安全建议

部署完成后请确认：

- [ ] 已修改默认 root 密码
- [ ] 已关闭公开注册
- [ ] 已启用 2FA
- [ ] 仅有必要端口开放（22, 80, 443）
- [ ] HTTPS 证书有效（`sudo certbot certificates`）
- [ ] 数据库密码使用强随机（已自动生成）
- [ ] 已配置自动备份 + 异地同步
- [ ] SESSION_SECRET 和 CRYPTO_SECRET 已设置

**绝对不要**：
- ❌ 把 `.env` / `*.pem` / `*.key` 提交到 Git
- ❌ 把仓库改为 Public（除非移除所有真实配置）
- ❌ 直接暴露 3000 端口到公网（必须套 Nginx）

---

## 📊 Dashboard 预览

部署后访问 `https://api.你的域名.com`，你会看到：

- 🏠 **首页**：今日请求数 / 今日花费 / 在线用户
- 📈 **用量查询**：按时间 / 模型 / 用户维度统计 + 图表
- 🔌 **渠道管理**：所有上游平台的 Key + 健康状态
- 👥 **用户管理**：多用户 + 配额 + 限速
- 🎫 **令牌管理**：API Token 签发 + 用量追踪
- ⚙️ **系统设置**：2FA / 注册 / 限速 / 模型重定向

---

## 💰 成本预估

| 部署规模 | VPS | 模型 API | 总计/月 |
|---------|-----|---------|--------|
| 个人轻度 | ¥35 | ¥50 | **¥85** |
| 个人中度 | ¥35 | ¥150 | **¥185** |
| 小团队（5 人）| ¥70 | ¥500 | **¥570** |

详细成本控制策略见 `docs/05-维护与扩展.md`。

---

## 🆘 遇到问题？

### 快速诊断

| 症状 | 第一步 |
|------|--------|
| Dashboard 打不开 | `docker compose ps` 看容器是否运行 |
| API 502/504 | `docker compose logs new-api --tail 50` |
| HTTPS 过期 | `sudo certbot renew` |
| 数据库锁 | `docker compose restart mysql` |
| 网络问题 | `curl -I https://api.你的域名.com` |

### 获取帮助

- 📖 查 [docs/](docs/) 目录对应文档
- 🐛 提交 [GitHub Issue](https://github.com/hcming2026/ai-dashboard/issues)
- 💬 New-API 官方社区：https://github.com/QuantumNous/new-api/discussions
- 📧 Vultr/DO 工单（VPS 故障时）

---

## 🗺️ 路线图

- [x] Docker Compose 一键部署
- [x] HTTPS + Nginx 反代
- [x] 多客户端支持
- [x] 自动备份脚本
- [ ] Grafana 监控面板
- [ ] MCP 接入
- [ ] 多 VPS 高可用

---

## 🤝 贡献

本仓库为个人 / 小团队使用模板，欢迎 Fork 后按需修改。

如果你有改进建议：
1. Fork 本仓库
2. 创建特性分支（`git checkout -b feature/AmazingFeature`）
3. 提交改动（`git commit -m 'Add some AmazingFeature'`）
4. 推送到分支（`git push origin feature/AmazingFeature`）
5. 提交 Pull Request

---

## 📄 许可证

本项目配置文件采用 **MIT 许可证**。

⚠️ **注意**：[New-API](https://github.com/QuantumNous/new-api) 本身采用 **AGPL-3.0 许可证**。
- ✅ **个人自用**：无任何限制
- ⚠️ **二次分发**：衍生作品也必须开源
- ❌ **闭源商用**：需购买商业授权

---

## 🙏 致谢

- [QuantumNous/new-api](https://github.com/QuantumNous/new-api) — 核心网关
- [Docker](https://www.docker.com/) — 容器化部署
- [Let's Encrypt](https://letsencrypt.org/) — 免费 HTTPS 证书

---

<p align="center">
  如果这个项目帮到了你，给个 ⭐️ Star 支持一下！
</p>

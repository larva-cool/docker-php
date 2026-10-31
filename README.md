# PHP Docker 镜像项目

## 项目概述

[![Docker](https://github.com/larva-cool/docker-php/actions/workflows/docker-publish.yml/badge.svg?branch=master)](https://github.com/larva-cool/docker-php/actions/workflows/docker-publish.yml)

这个项目提供了多个 PHP 版本的标准化 Docker 开发环境，旨在为 PHP 应用开发和部署提供一致、高效的容器化解决方案。项目支持 PHP 8.0、8.1、8.2、8.3、8.4 和 8.5，并提供标准版、FPM 版及 Alpine 版镜像。

## 项目结构

项目按 PHP 版本和镜像变体组织目录：

```text
├── 8.0/                  # PHP 8.0 标准版
├── 8.0-fpm/              # PHP 8.0 FPM 版
├── 8.1-alpine/           # PHP 8.1 Alpine 版
├── ...                   # 其他版本和变体
├── 8.5/                  # PHP 8.5 标准版
├── 8.5-fpm/              # PHP 8.5 FPM 版
├── 8.5-alpine/           # PHP 8.5 Alpine 版
├── .github/workflows/    # GitHub Actions 构建与发布配置
├── build-images.sh       # 镜像构建脚本
├── push-images.sh        # 镜像推送脚本
└── README.md             # 项目文档
```

每个镜像目录包含对应的 `Dockerfile` 和 PHP 配置。标准版与 FPM 版基于 Ubuntu 24.04，Alpine 版使用各目录 `Dockerfile` 中指定的 Alpine Linux 版本。

## 技术特点

### 基础环境
- **标准版与 FPM 版**: 基于 Ubuntu 24.04 LTS
- **Alpine 版**: 基于 Alpine Linux，具体版本以对应 `Dockerfile` 为准
- **镜像源优化**: 使用中国科学技术大学镜像源（mirrors.ustc.edu.cn），提高国内环境下的构建速度
- **时区设置**: 统一使用 UTC 时区

### PHP 环境

每个 PHP 版本均安装了以下扩展套件：

- **数据库支持**:
  - PostgreSQL (pgsql)
  - MySQL/MariaDB (mysql)
  - SQLite3 (sqlite3)
  - MongoDB (mongodb)

- **Web 功能扩展**:
  - cURL (curl)
  - 多字节字符串 (mbstring)
  - XML 处理 (xml)
  - ZIP 处理 (zip)
  - 数学扩展 (bcmath)
  - SOAP (soap)
  - LDAP (ldap)

- **性能优化扩展**:
  - Redis 客户端 (redis)
  - Swoole 协程框架 (swoole)
  - Memcached 客户端 (memcached)
  - 序列化优化 (msgpack, igbinary)

- **图像处理**:
  - GD 库 (gd)
  - ImageMagick (imagick)

- **其他实用扩展**:
  - IMAP 电子邮件处理 (imap)
  - 国际化 (intl)
  - 命令行读取 (readline)

### 开发工具
- **依赖管理**: Composer
- **数据库客户端**: MySQL Client
- **版本控制**: Git

## 容器管理

标准版和 Alpine 版默认启动交互式 PHP Shell（`php -a`），适合命令行操作和脚本执行；FPM 版默认启动 `php-fpm`，用于配合 Nginx、Apache 等 Web 服务器。

### PHP 配置

每个版本的 `php.ini` 包含以下关键配置：
- 最大 POST 大小: 100M
- 最大上传文件大小: 100M
- 变量顺序: EGPCS (Environment, GET, POST, Cookie, Server)

## 使用方法

### 构建镜像

#### 使用快速构建脚本

项目提供了 `build-images.sh` 脚本，可以快速构建所有或指定版本的镜像：

```bash
# 串行构建所有版本镜像，默认标签为 php:<版本>
./build-images.sh

# 构建一个或多个指定版本
./build-images.sh 8.2 8.3-fpm

# 并行构建所有版本
./build-images.sh --parallel

# 指定镜像仓库，例如构建 ghcr.io/xutongle/php:8.5-fpm
./build-images.sh --repo ghcr.io/xutongle/php 8.5-fpm

# 查看完整参数说明
./build-images.sh --help
```

#### 手动构建

以 PHP 8.2 为例，手动构建镜像的命令如下：

```bash
cd 8.2
docker build -t php:8.2 .
```

### 运行容器

#### 基本运行

标准版和 Alpine 版默认启动交互式 PHP Shell。以 PHP 8.2 标准版为例：

```bash
docker run -it --rm php:8.2
```

#### 执行 PHP 脚本

```bash
docker run -it --rm -v $(pwd):/app php:8.2 php your-script.php
```

#### 运行 Composer 命令

```bash
docker run -it --rm -v $(pwd):/app php:8.2 composer install
```

#### 启动内置服务器

```bash
docker run -it --rm -p 8000:8000 -v $(pwd):/app php:8.2 php -S 0.0.0.0:8000
```

## 环境变量

当前版本的镜像使用简化设计，不需要特定环境变量配置，可直接使用默认设置。

## 注意事项

1. **工作目录**: 应用代码建议挂载到 `/app` 目录
2. **扩展说明**: 本镜像不包含 Xdebug 和 PCOV 等代码覆盖率工具，如需这些功能，请自行扩展 Dockerfile
3. **默认命令**: 标准版和 Alpine 版默认运行交互式 PHP Shell；FPM 版默认运行 `php-fpm`

## 镜像版本

| PHP 版本 | 标准版标签 | FPM 版标签 | Alpine 版标签 |
|----------|------------|------------|---------------|
| 8.0      | `8.0`      | `8.0-fpm`  | -             |
| 8.1      | `8.1`      | `8.1-fpm`  | `8.1-alpine`  |
| 8.2      | `8.2`      | `8.2-fpm`  | `8.2-alpine`  |
| 8.3      | `8.3`      | `8.3-fpm`  | `8.3-alpine`  |
| 8.4      | `8.4`      | `8.4-fpm`  | `8.4-alpine`  |
| 8.5      | `8.5`      | `8.5-fpm`  | `8.5-alpine`  |

## 维护信息

- **维护者**: Tongle Xu
- **基础镜像**: Ubuntu 24.04 LTS / Alpine Linux
- **最后更新**: 2026 年

## 扩展建议

如需根据项目需求扩展镜像功能，可以考虑：

1. 添加特定的 PHP 扩展
2. 安装项目依赖的系统工具
3. 调整 PHP 配置参数
4. 集成 Web 服务器（如 Nginx、Apache）

## 镜像发布与推送

### GitHub Actions 自动发布

GitHub Actions 工作流调用 `build-images.sh` 构建全部镜像，发布仓库为 `ghcr.io/<仓库所有者>/php`，标签与“镜像版本”表格一致。例如，PHP 8.5 FPM 版镜像为 `ghcr.io/<仓库所有者>/php:8.5-fpm`。镜像名独立于 Git 仓库名。

推送使用个人 PAT，请在仓库的 **Settings → Secrets and variables → Actions** 中创建名为 `GHCR_PAT` 的 Secret。Fine-grained PAT 或 Classic PAT 均需具备 `packages: write` 权限。首次推送后，如有需要，可在 GHCR 包页面手动关联 Git 仓库。

- **Pull Request**: 仅构建镜像，不推送、不签名。
- **非 Pull Request 事件**: 构建全部镜像并推送到 GHCR，然后使用 cosign 对每个已发布镜像的 digest 进行签名。触发方式包括 `master` 分支推送、`v*.*.*` 标签推送和定时任务。

### 手动推送

`push-images.sh` 将本地 `php:<版本>` 镜像打标签后推送，并自动执行 `docker login`。默认目标仓库由环境变量 `CNB_DOCKER_REGISTRY` 和 `CNB_REPO_SLUG_LOWERCASE` 组成：

```bash
export CNB_DOCKER_REGISTRY=registry.cn-hangzhou.aliyuncs.com
export CNB_REPO_SLUG_LOWERCASE=xutongle/php

# 推送所有版本镜像
./push-images.sh

# 推送一个或多个指定版本
./push-images.sh 8.2 8.5-fpm
```

也可以通过 `--registry` 指定镜像仓库地址，此时目标仓库为 `<仓库地址>/xutongle/php`：

```bash
./push-images.sh --registry registry.cn-hangzhou.aliyuncs.com 8.2
```

推送前请先使用 `build-images.sh` 构建对应的本地镜像，并准备好目标仓库的登录凭证。

## 许可证

本项目采用 MIT 许可证。
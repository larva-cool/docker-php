# PHP Docker 镜像项目

## 项目概述

这个项目提供了多个 PHP 版本的标准化 Docker 开发环境，旨在为 PHP 应用开发和部署提供一致、高效的容器化解决方案。项目支持 PHP 8.0、8.1、8.2、8.3 和 8.4 版本，所有版本均基于 Ubuntu 24.04 构建，并包含完整的 PHP 扩展套件。

## 项目结构

项目采用按 PHP 版本分类的目录结构：

```
├── 8.0/            # PHP 8.0 版本配置
│   ├── Dockerfile      # Docker 构建文件
│   └── php.ini         # PHP 配置文件
├── 8.1/            # PHP 8.1 版本配置
├── 8.2/            # PHP 8.2 版本配置
├── 8.3/            # PHP 8.3 版本配置
├── 8.4/            # PHP 8.4 版本配置
├── 8.5/            # PHP 8.5 版本配置
├── README.md           # 项目文档
├── build-images.sh     # 快速构建脚本
└── push-images.sh      # 镜像推送脚本
```

每个版本目录包含相同的文件结构，确保了不同 PHP 版本间的一致性和可预测性。

## 技术特点

### 基础环境
- **操作系统**: Ubuntu 24.04 LTS
- **镜像源优化**: 使用中国科学技术大学镜像源(mirrors.ustc.edu.cn)，提高国内环境下的构建速度
- **时区设置**: 统一使用 UTC 时区
- **APT 优化**: 配置了缓存和代理优化参数

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

当前版本的镜像采用简化设计，默认启动交互式 PHP Shell（php -a），适合命令行操作和脚本执行。

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
# 构建所有版本镜像
./build-images.sh

# 构建特定版本镜像
./build-images.sh 8.2
```

#### 手动构建

以 PHP 8.2 为例，手动构建镜像的命令如下：

```bash
cd 8.2
docker build -t php:8.2 .
```

### 运行容器

#### 基本运行

默认情况下，容器启动交互式 PHP Shell：

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
3. **交互式模式**: 镜像默认以交互式 PHP Shell 运行，适合命令行操作

## 版本兼容性

| PHP 版本 | 最低 Ubuntu 版本 | 扩展完整性 |
|----------|----------------|------------|
| 8.0      | 24.04          | 完整支持   |
| 8.1      | 24.04          | 完整支持   |
| 8.2      | 24.04          | 完整支持   |
| 8.3      | 24.04          | 完整支持   |
| 8.4      | 24.04          | 完整支持   |

## 维护信息

- **维护者**: Tongle Xu
- **基础镜像**: Ubuntu 24.04 LTS
- **最后更新**: 2026 年

## 扩展建议

如需根据项目需求扩展镜像功能，可以考虑：

1. 添加特定的 PHP 扩展
2. 安装项目依赖的系统工具
3. 调整 PHP 配置参数
4. 集成 Web 服务器（如 Nginx、Apache）

## 镜像推送

项目提供了 `push-images.sh` 脚本，可以将构建好的镜像推送到阿里云容器镜像服务：

```bash
# 推送所有版本镜像
./push-images.sh

# 推送特定版本镜像
./push-images.sh 8.2

# 指定镜像标签
./push-images.sh --tag latest
```

推送前需要先登录阿里云容器镜像服务：
```bash
docker login registry.cn-hangzhou.aliyuncs.com
```

镜像将被推送到 `registry.cn-hangzhou.aliyuncs.com/xutongle/php` 仓库。

## 许可证

本项目采用 MIT 许可证。
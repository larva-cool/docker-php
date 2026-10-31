#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}PHP Docker 镜像推送工具${NC}"
echo -e "${BLUE}========================================${NC}"

# 默认配置
ALIYUN_REGISTRY="${CNB_DOCKER_REGISTRY}"
ALIYUN_REPO="${CNB_DOCKER_REGISTRY}/${CNB_REPO_SLUG_LOWERCASE}"
PHP_VERSIONS=(
  "8.0"
  "8.0-fpm"
  "8.1"
  "8.1-fpm"
  "8.1-alpine"
  "8.2"
  "8.2-fpm"
  "8.2-alpine"
  "8.3"
  "8.3-fpm"
  "8.3-alpine"
  "8.4"
  "8.4-fpm"
  "8.4-alpine"
  "8.5"
  "8.5-fpm"
  "8.5-alpine"
)

# 显示帮助信息
show_help() {
  echo -e "\n${YELLOW}使用方法:${NC} $0 [选项] [版本]\n"
  echo -e "${YELLOW}选项:${NC}"
  echo -e "  -h, --help        显示此帮助信息"
  echo -e "  -r, --registry    指定仓库地址 (默认: ${ALIYUN_REGISTRY})"
  echo -e "\n${YELLOW}示例:${NC}"
  echo -e "  $0               推送所有版本镜像"
  echo -e "  $0 8.2           只推送 PHP 8.2 版本镜像"
  echo -e "\n"
}

# 检查 Docker 是否安装
check_docker() {
  if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装或不在 PATH 中${NC}"
    exit 1
  fi
  
  if ! docker info &> /dev/null; then
    echo -e "${RED}错误: Docker 守护进程未运行或无权限访问${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Docker 检查通过${NC}"
}

# 登录阿里云 Docker Registry
login_aliyun() {
  echo -e "${YELLOW}正在登录容器镜像服务...${NC}"
  docker login ${ALIYUN_REGISTRY} || {
    echo -e "${RED}登录失败，请检查您的凭证${NC}"
    exit 1
  }
  echo -e "${GREEN}登录成功${NC}"
}

# 推送单个镜像
push_image() {
  local version=$1
  local local_image="php:${version}"
  local remote_image="${ALIYUN_REPO}:${version}"
  
  echo -e "\n${BLUE}正在推送 PHP ${version} 镜像...${NC}"
  
  # 检查本地镜像是否存在
  if ! docker images -q "${local_image}" > /dev/null; then
    echo -e "${RED}错误: 本地镜像 ${local_image} 不存在，请先构建镜像${NC}"
    return 1
  fi
  
  # 打标签
  echo -e "${YELLOW}正在为镜像打标签...${NC}"
  docker tag "${local_image}" "${remote_image}" || {
    echo -e "${RED}打标签失败${NC}"
    return 1
  }
  
  # 推送镜像
  echo -e "${YELLOW}正在推送镜像 ${remote_image}...${NC}"
  if docker push "${remote_image}"; then
    echo -e "${GREEN}镜像 ${remote_image} 推送成功${NC}"
    return 0
  else
    echo -e "${RED}镜像 ${remote_image} 推送失败${NC}"
    return 1
  fi
  
  return 0
}

# 推送所有指定版本的镜像
push_images() {
  local versions=($@)
  local success_count=0
  local fail_count=0
  local start_time=$(date +%s)
  
  for version in "${versions[@]}"; do
    if push_image "${version}"; then
      success_count=$((success_count + 1))
    else
      fail_count=$((fail_count + 1))
    fi
  done
  
  local end_time=$(date +%s)
  local duration=$((end_time - start_time))
  
  echo -e "\n${BLUE}========================================${NC}"
  echo -e "${GREEN}推送完成${NC}"
  echo -e "成功: ${GREEN}${success_count}${NC}"
  echo -e "失败: ${RED}${fail_count}${NC}"
  echo -e "总耗时: ${YELLOW}${duration}${NC} 秒"
  echo -e "${BLUE}========================================${NC}"
  
  return $fail_count
}

# 主函数
main() {
  # 解析命令行参数
  local specific_versions=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      -h|--help)
        show_help
        exit 0
        ;;
      -t|--tag)
        echo -e "${YELLOW}警告: 不再支持标签参数，将忽略此选项${NC}"
        if [ -n "$2" ]; then
          shift 2
        else
          shift 1
        fi
        ;;
      -r|--registry)
        ALIYUN_REGISTRY="$2"
        ALIYUN_REPO="${ALIYUN_REGISTRY}/xutongle/php"
        shift 2
        ;;
      *)
        # 检查是否是有效的 PHP 版本
        if [[ " ${PHP_VERSIONS[*]} " == *" $1 "* ]]; then
          specific_versions+=("$1")
        else
          echo -e "${RED}错误: 无效的 PHP 版本 '$1'${NC}"
          echo -e "有效的版本: ${PHP_VERSIONS[*]}"
          exit 1
        fi
        shift
        ;;
    esac
  done
  
  # 如果没有指定特定版本，使用所有版本
  local versions_to_push=(${specific_versions[@]:-${PHP_VERSIONS[@]}})
  
  echo -e "${YELLOW}配置信息:${NC}"
  echo -e "仓库: ${ALIYUN_REPO}"
  echo -e "PHP 版本: ${versions_to_push[*]}"
  
  # 执行推送流程
  check_docker
  login_aliyun
  push_images "${versions_to_push[@]}"
  local result=$?
  
  if [[ $result -eq 0 ]]; then
    echo -e "\n${GREEN}所有镜像推送成功！${NC}"
  else
    echo -e "\n${RED}部分镜像推送失败，请检查错误信息${NC}"
  fi
  
  return $result
}

# 执行主函数
main "$@"
exit $?
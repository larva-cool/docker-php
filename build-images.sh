#!/bin/bash

# PHP Docker 镜像快速构建脚本
# 支持构建所有或特定版本的PHP镜像

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 默认配置
DOCKER_REPO="php"
BUILD_PARALLEL=false
PHP_VERSIONS=(
#  "8.0"
#  "8.0-fpm"
#  "8.1"
#  "8.1-fpm"
#  "8.1-alpine"
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
    echo -e "${BLUE}PHP Docker 镜像构建脚本${NC}"
    echo -e "用法: $0 [选项] [版本...]"
    echo -e ""
    echo -e "选项:"
    echo -e "  -h, --help            显示此帮助信息"
    echo -e "  -r, --repo <仓库名>    指定Docker镜像仓库名称 (默认为 'php')"
    echo -e "  -p, --parallel        并行构建镜像以提高速度"
    echo -e ""
    echo -e "示例:"
    echo -e "  $0                    构建所有PHP版本镜像"
    echo -e "  $0 8.2 8.3           只构建PHP 8.2和8.3版本镜像"
    echo -e "  $0 -p                并行构建所有镜像"
    echo -e "  $0 -r myphp 8.2      构建PHP 8.2镜像，标签为myphp:8.2"
}

# 检查Docker是否可用
check_docker() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker命令未找到，请确保已安装Docker${NC}"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        echo -e "${RED}错误: 无法连接到Docker守护进程，请确保Docker服务正在运行${NC}"
        exit 1
    fi
}

# 构建单个镜像
build_image() {
    local version=$1
    local image_name="${DOCKER_REPO}:${version}"
    
    echo -e "${BLUE}开始构建 PHP ${version} 镜像...${NC}"
    
    if [ ! -d "${version}" ]; then
        echo -e "${RED}错误: PHP ${version} 目录不存在${NC}"
        return 1
    fi
    
    cd "${version}"
    if docker build -t "${image_name}" .; then
        echo -e "${GREEN}成功: PHP ${version} 镜像构建完成 -> ${image_name}${NC}"
        cd ..
        return 0
    else
        echo -e "${RED}失败: PHP ${version} 镜像构建失败${NC}"
        cd ..
        return 1
    fi
}

# 并行构建函数
parallel_build() {
    local versions=($1)
    local pids=()
    local failed=0
    
    for version in "${versions[@]}"; do
        (build_image "${version}") &
        pids+=($!)
    done
    
    # 等待所有进程完成
    for pid in "${pids[@]}"; do
        if ! wait "${pid}"; then
            failed=$((failed + 1))
        fi
    done
    
    return ${failed}
}

# 串行构建函数
serial_build() {
    local versions=($1)
    local failed=0
    
    for version in "${versions[@]}"; do
        if ! build_image "${version}"; then
            failed=$((failed + 1))
        fi
    done
    
    return ${failed}
}

# 主函数
main() {
    local selected_versions=()
    local skip_args=0
    
    # 解析命令行参数
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                return 0
                ;;
            -r|--repo)
                if [ -n "$2" ]; then
                    DOCKER_REPO="$2"
                    skip_args=2
                else
                    echo -e "${RED}错误: 请为 --repo 选项提供值${NC}"
                    return 1
                fi
                ;;
            -p|--parallel)
                BUILD_PARALLEL=true
                skip_args=1
                ;;
            -t|--tag)
                echo -e "${YELLOW}警告: 不再支持标签后缀参数，将忽略此选项${NC}"
                if [ -n "$2" ]; then
                    skip_args=2
                else
                    skip_args=1
                fi
                ;;
            *)
                # 检查是否是有效的PHP版本
                if [[ " ${PHP_VERSIONS[*]} " == *" $1 "* ]]; then
                    selected_versions+=($1)
                else
                    echo -e "${YELLOW}警告: 忽略无效的PHP版本 '$1'${NC}"
                fi
                skip_args=1
                ;;
        esac
        
        # 跳过已处理的参数
        shift $skip_args
    done
    
    # 如果没有选择特定版本，则构建所有版本
    if [ ${#selected_versions[@]} -eq 0 ]; then
        selected_versions=(${PHP_VERSIONS[@]})
    fi
    
    echo -e "${YELLOW}将构建以下PHP版本: ${selected_versions[*]}${NC}"
    echo -e "${YELLOW}镜像仓库: ${DOCKER_REPO}${NC}"
    echo -e "${YELLOW}并行构建: ${BUILD_PARALLEL}${NC}"
    echo ""
    
    # 开始构建
    start_time=$(date +%s)
    
    if [ "$BUILD_PARALLEL" = true ]; then
        echo -e "${BLUE}正在并行构建镜像...${NC}"
        parallel_build "${selected_versions[*]}"
    else
        echo -e "${BLUE}正在串行构建镜像...${NC}"
        serial_build "${selected_versions[*]}"
    fi
    
    local result=$?
    end_time=$(date +%s)
    execution_time=$((end_time - start_time))
    
    echo ""
    echo -e "${BLUE}构建完成! 总耗时: ${execution_time} 秒${NC}"
    
    if [ $result -eq 0 ]; then
        echo -e "${GREEN}所有镜像构建成功!${NC}"
        return 0
    else
        echo -e "${RED}构建失败: 有 ${result} 个镜像构建失败${NC}"
        return 1
    fi
}

# 执行主函数
check_docker
main "$@"
exit $?
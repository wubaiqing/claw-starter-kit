#!/usr/bin/env bash
set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ENV_EXAMPLE="$PROJECT_ROOT/.env.example"

# 检测当前 shell
detect_shell() {
    if [ -n "$ZSH_VERSION" ]; then
        echo "zsh"
    elif [ -n "$BASH_VERSION" ]; then
        echo "bash"
    else
        # 检查默认 shell
        echo "$SHELL" | grep -q "zsh" && echo "zsh" || echo "bash"
    fi
}

# 获取 shell 配置文件路径
get_shell_config() {
    local shell_type="$1"
    case "$shell_type" in
        zsh)
            echo "$HOME/.zshrc"
            ;;
        bash)
            if [ -f "$HOME/.bashrc" ]; then
                echo "$HOME/.bashrc"
            else
                echo "$HOME/.bash_profile"
            fi
            ;;
        *)
            echo "$HOME/.profile"
            ;;
    esac
}

# 检查环境变量是否已存在
env_exists() {
    local config_file="$1"
    local var_name="$2"
    grep -q "^export $var_name=" "$config_file" 2>/dev/null
}

# 注入环境变量
inject_env() {
    local env_file="$1"
    local config_file="$2"

    if [ ! -f "$env_file" ]; then
        echo -e "${RED}错误: $env_file 文件不存在${NC}"
        exit 1
    fi

    echo -e "${YELLOW}读取 $env文件...${NC}"

    # 读取 .env.example 中的非注释、非空行
    while IFS='=' read -r key value; do
        # 跳过注释和空行
        [[ "$key" =~ ^#.*$ ]] && continue
        [[ -z "$key" ]] && continue

        # 去除 key 和 value 的空格
        key=$(echo "$key" | xargs)
        value=$(echo "$value" | xargs)

        # 跳过空值（用户未填写）
        if [ -z "$value" ]; then
            echo -e "${YELLOW}跳过未填写的变量: $key${NC}"
            continue
        fi

        # 检查变量是否已存在
        if env_exists "$config_file" "$key"; then
            echo -e "${YELLOW}变量 $key 已存在于 $config_file，跳过${NC}"
        else
            # 添加到配置文件
            echo "" >> "$config_file"
            echo "# Added by claw-starter-kit inject-env.sh" >> "$config_file"
            echo "export $key=\"$value\"" >> "$config_file"
            echo -e "${GREEN}✓ 已添加: $key${NC}"
        fi
    done < "$env_file"
}

main() {
    echo -e "${GREEN}=== 环境变量注入工具 ===${NC}\n"

    # 检测 shell 和配置文件
    shell_type=$(detect_shell)
    config_file=$(get_shell_config "$shell_type")

    echo -e "检测到 Shell: ${YELLOW}$shell_type${NC}"
    echo -e "配置文件: ${YELLOW}$config_file${NC}\n"

    # 如果 .env.example 不存在，提示用户
    if [ ! -f "$ENV_EXAMPLE" ]; then
        echo -e "${RED}错误: .env.example 文件不存在${NC}"
        exit 1
    fi

    # 提示用户填写 .env.example
    echo -e "${YELLOW}请先在 $ENV_EXAMPLE 中填写环境变量的值${NC}"
    echo -e "${YELLOW}按任意键继续，或 Ctrl+C 取消...${NC}"
    read -n 1 -s

    # 注入环境变量
    inject_env "$ENV_EXAMPLE" "$config_file"

    echo -e "\n${GREEN}=== 完成 ===${NC}"
    echo -e "请运行以下命令使配置生效："
    echo -e "${YELLOW}source $config_file${NC}"
}

main "$@"

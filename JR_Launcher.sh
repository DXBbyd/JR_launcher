#!/bin/bash

# JR_Launcher - Jianer & NapCat 一键管理脚本
# 分模块管理模式

# 检查配置文件夹，如果不存在则释放
check_and_install_config() {
    if [ ! -d "/root/JR_Config" ]; then
        echo "==================================="
        echo "  检测到 JR_Config 配置文件夹不存在"
        echo "  正在从服务器释放配置文件..."
        echo "==================================="
        echo ""

        # 释放配置文件
        cd /root
        if ! wget -O J.zip "https://RBfrom.havugu.cn/Download/J.zip"; then
            echo "[错误] 释放配置文件失败！"
            echo "请检查网络连接或手动释放后重试"
            exit 1
        fi

        echo "[成功] 配置文件释放完成"
        echo "正在解压..."
        
        # 解压文件
        if ! unzip -o J.zip -d /root/; then
            echo "[错误] 解压配置文件失败！"
            exit 1
        fi
        
        # 清理下载的压缩包
        rm -f J.zip
        
        echo "[成功] 配置文件解压完成"
        echo ""
        
        # 检查文件完整性
        echo "正在检查文件完整性..."
        if [ ! -d "/root/JR_Config" ]; then
            echo "[错误] 配置文件夹不存在，解压可能失败！"
            exit 1
        fi
        
        # 检查必要的子文件夹
        local required_dirs=("config" "functions" "scripts")
        local missing_dirs=()
        
        for dir in "${required_dirs[@]}"; do
            if [ ! -d "/root/JR_Config/$dir" ]; then
                missing_dirs+=("$dir")
            fi
        done
        
        if [ ${#missing_dirs[@]} -gt 0 ]; then
            echo "[警告] 以下必要的文件夹缺失: ${missing_dirs[*]}"
            echo "配置可能不完整，某些功能可能无法使用"
        else
            echo "[成功] 文件完整性检查通过"
        fi
        
        echo ""
        echo "==================================="
        echo "  配置文件安装完成！"
        echo "==================================="
        echo ""
        read -p "按回车继续..."
    fi
}

# 检查并安装必要依赖
check_dependencies() {
    local missing_deps=()
    
    # 检查必要工具
    for cmd in screen unzip wget curl python3 git; do
        if ! command -v $cmd &> /dev/null; then
            missing_deps+=($cmd)
        fi
    done
    
    # 检查 pip 是否可用
    if ! command -v pip3 &> /dev/null && ! python3 -m pip --version &> /dev/null; then
        echo "检测到 python3-pip 未安装"
        echo "正在尝试自动安装 python3-pip..."
        
        # 检查是否有 sudo 权限
        if command -v sudo &> /dev/null; then
            sudo apt-get update -y
            sudo apt-get install -y python3-pip
        else
            apt-get update -y
            apt-get install -y python3-pip
        fi
        
        # 再次检查 pip 是否可用
        if command -v pip3 &> /dev/null || python3 -m pip --version &> /dev/null; then
            echo "[成功] python3-pip 安装成功"
        else
            echo "[错误] python3-pip 安装失败或仍不可用"
            echo "请手动安装: apt-get install python3-pip"
            exit 1
        fi
    fi
    
    # 如果有缺失的依赖，尝试安装
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "检测到缺少以下依赖: ${missing_deps[*]}"
        echo "正在尝试自动安装..."
        
        # 检查是否有 sudo 权限
        if command -v sudo &> /dev/null; then
            sudo apt-get update -y
            sudo apt-get install -y ${missing_deps[*]}
        else
            # 没有 sudo，尝试直接运行
            apt-get update -y
            apt-get install -y ${missing_deps[*]}
        fi
        
        # 再次检查
        local still_missing=()
        for cmd in "${missing_deps[@]}"; do
            if ! command -v $cmd &> /dev/null; then
                still_missing+=($cmd)
            fi
        done
        
        if [ ${#still_missing[@]} -gt 0 ]; then
            echo "错误: 无法安装以下依赖: ${still_missing[*]}"
            echo "请手动安装后再运行脚本"
            exit 1
        else
            echo "依赖安装完成"
        fi
    fi
}

# 检测 NapCat 状态
check_napcat_status() {
    if screen -list | grep -q "napcat"; then
        echo -e "\033[32m[运行中]\033[0m"
    else
        echo -e "\033[31m[未运行]\033[0m"
    fi
}

# 检测 Jianer 状态
check_jianer_status() {
    if screen -list | grep -q "jianer"; then
        echo -e "\033[32m[运行中]\033[0m"
    else
        echo -e "\033[31m[未运行]\033[0m"
    fi
}

# 显示菜单
show_menu() {
    clear
    echo "==================================="
    echo "    JR_Launcher - 启动器"
    echo "    简单·迅速·便捷"
    echo "==================================="
    echo ""
    echo "服务状态："
    echo "  NapCat: $(check_napcat_status)"
    echo "  Jianer: $(check_jianer_status)"
    echo ""
    echo "请选择操作："
    echo "【安装】"
    echo "  1. 安装 Jianer"
    echo "  2. 安装 NapCat"
    echo "  3. 安装 venv"
    echo ""
    echo "【配置】"
    echo "  4. 配置 Jianer"
    echo "  5. 配置 NapCat"
    echo ""
    echo "【启动/停止】"
    echo "  6. 后台启动 Jianer"
    echo "  7. 终止 Jianer"
    echo "  8. 后台启动 NapCat"
    echo "  9. 终止 NapCat"
    echo ""
    echo "【日志】"
    echo "  10. 查看 Jianer 日志"
    echo "  11. 查看 NapCat 日志"
    echo ""
    echo "【维护】"
    echo "  12. 切换 Jianer 版本"
    echo ""
    echo "  0. 退出脚本"
    echo ""
}

# 主循环
while true; do
    # 每次运行前检查配置和依赖
    check_and_install_config
    check_dependencies
    
    show_menu
    read -p "请输入选项 [0-12]: " choice
    echo ""
    
    case $choice in
        1)
            echo "开始安装 Jianer..."
            echo ""
            # 调用安装 Jianer 的脚本
            bash /root/JR_Config/scripts/install_jianer.sh
            ;;
        2)
            echo "开始安装 NapCat..."
            echo ""
            # 调用安装 NapCat 的脚本
            bash /root/JR_Config/scripts/install_napcat.sh
            ;;
        3)
            echo "开始安装 venv..."
            echo ""
            # 调用安装 venv 的脚本
            bash /root/JR_Config/scripts/install_venv.sh
            ;;
        4)
            echo "开始配置 Jianer..."
            echo ""
            # 调用配置 Jianer 的脚本
            bash /root/JR_Config/scripts/config_jianer.sh
            ;;
        5)
            echo "开始配置 NapCat..."
            echo ""
            # 调用配置 NapCat 的脚本
            bash /root/JR_Config/scripts/config_napcat.sh
            ;;
        6)
            echo "后台启动 Jianer..."
            echo ""
            # 调用启动 Jianer 的脚本
            bash /root/JR_Config/scripts/start_jianer.sh
            ;;
        7)
            echo "终止 Jianer..."
            echo ""
            # 调用停止 Jianer 的脚本
            bash /root/JR_Config/scripts/stop_jianer.sh
            ;;
        8)
            echo "后台启动 NapCat..."
            echo ""
            # 调用启动 NapCat 的脚本
            bash /root/JR_Config/scripts/start_napcat.sh
            ;;
        9)
            echo "终止 NapCat..."
            echo ""
            # 调用停止 NapCat 的脚本
            bash /root/JR_Config/scripts/stop_napcat.sh
            ;;
        10)
            echo "查看 Jianer 日志..."
            echo ""
            # 调用查看 Jianer 日志的脚本
            bash /root/JR_Config/scripts/view_jianer_log.sh
            ;;
        11)
            echo "查看 NapCat 日志..."
            echo ""
            # 调用查看 NapCat 日志的脚本
            bash /root/JR_Config/scripts/view_napcat_log.sh
            ;;
        12)
            echo "切换 Jianer 版本..."
            echo ""
            # 调用切换版本的脚本
            bash /root/JR_Config/scripts/switch_version.sh
            ;;
        0)
            echo "退出脚本..."
            break
            ;;
        *)
            echo "无效选项，请重新输入！"
            echo ""
            read -p "按回车继续..."
            ;;
    esac
done
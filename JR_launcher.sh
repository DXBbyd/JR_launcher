#!/bin/bash

# Jianer - Launcher
# 适用于SR社区Jianer项目

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

# 检测 uv 包管理器
check_uv() {
    if command -v uv &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# 检测是否使用 uv
is_uv_enabled() {
    local project_dir=$1
    if [ -f "$project_dir/installer_config.json" ]; then
        local uv_enabled=$(python3 -c "import json; f=open('$project_dir/installer_config.json'); d=json.load(f); print(str(d.get('use_uv', False)).lower())" 2>/dev/null)
        if [ "$uv_enabled" = "true" ]; then
            return 0
        fi
    fi
    return 1
}

# 设置 uv 使用状态
set_uv_enabled() {
    local project_dir=$1
    local enabled=$2
    cat > "$project_dir/installer_config.json" << JSONEOF
{
  "use_uv": $enabled
}
JSONEOF
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
    echo "    Jianer - Launcher"
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
    echo "  0. 退出脚本"
    echo ""
}

# 配置函数
configure_jianer() {
    local mode=$1
    echo "==================================="
    echo "    配置 config.json"
    echo "==================================="
    echo ""
    
    if [ ! -d "Jianer_QQ_bot" ]; then
        echo "[错误] 未找到 Jianer_QQ_bot 目录"
        echo ""
        read -p "按回车继续..."
        return 1
    fi
    
    cd Jianer_QQ_bot
    
    # 检查 config.json 是否存在，不存在则创建默认配置
    if [ ! -f "config.json" ]; then
        echo "未找到 config.json，正在创建默认配置..."
        cat > config.json << EOF
{
  "owner": [0],
  "black_list": [],
  "silents": [],
  "Connection": {
    "mode": "FWS",
    "host": "127.0.0.1",
    "port": 5004,
    "listener_host": "127.0.0.1",
    "listener_port": 5003,
    "retries": 5,
    "satori_token": ""
  },
  "Log_level": "DEBUG",
  "protocol": "OneBot",
  "Others": {
    "gemini_key": "",
    "openai_key": "",
    "deepseek_key": "",
    "bot_name": "简儿",
    "bot_name_en": "Jianer",
    "ROOT_User": [""],
    "Auto_approval": [""],
    "reminder": "~",
    "slogan": "简单 可爱 个性 全知",
    "TTS": {
      "voiceColor": "zh-CN-XiaoyiNeural",
      "rate": "+0%",
      "volume": "+0%",
      "pitch": "+0Hz"
    },
    "compliment": [
      "啊！老……老公，别怎么说啦，人……人家好害羞的啦，人家还会努力的(*ᴗ͈ˬᴗ͈)ꕤ*.ﾟ",
      "啊~老公~你不要这么夸人家啦~〃∀〃",
      "唔……谢……谢谢老公啦🥰~"
    ]
  },
  "uin": 0
}
EOF
        echo "[成功] 默认配置已创建"
    fi
    
    # 读取现有配置
    bot_qq=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(str(d.get('owner', ['0'])[0]))" 2>/dev/null)
    bot_name_cn=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(d.get('Others', {}).get('bot_name', '简儿'))" 2>/dev/null)
    bot_name_en=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(d.get('Others', {}).get('bot_name_en', 'Jianer'))" 2>/dev/null)
    owner_qq=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(str(d.get('Others', {}).get('ROOT_User', [''])[0]))" 2>/dev/null)
    conn_host=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(d.get('Connection', {}).get('host', '127.0.0.1'))" 2>/dev/null)
    conn_port=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(d.get('Connection', {}).get('port', 5004))" 2>/dev/null)
    log_level=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(d.get('Log_level', 'DEBUG'))" 2>/dev/null)
    reminder=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(d.get('Others', {}).get('reminder', '~'))" 2>/dev/null)
    slogan=$(python3 -c "import json; f=open('config.json'); d=json.load(f); print(d.get('Others', {}).get('slogan', '简单 可爱 个性 全知'))" 2>/dev/null)
    
    echo "【必须配置的参数】"
    echo ""
    
    read -p "请输入机器人 QQ 号 [当前: ${bot_qq}]: " input
    bot_qq=${input:-$bot_qq}
    bot_uin=$bot_qq
    
    read -p "请输入机器人中文名字 [当前: ${bot_name_cn}]: " input
    bot_name_cn=${input:-$bot_name_cn}
    
    read -p "请输入机器人英文名字 [当前: ${bot_name_en}]: " input
    bot_name_en=${input:-$bot_name_en}
    
    read -p "请输入你的 QQ 号 (机器人主人) [当前: ${owner_qq}]: " input
    owner_qq=${input:-$owner_qq}
    
    echo ""
    echo "【连接配置】(直接回车使用默认值)"
    echo ""
    
    read -p "NapCat 运行地址 [默认: ${conn_host}]: " input
    conn_host=${input:-$conn_host}
    
    read -p "NapCat WebSocket 端口 [默认: ${conn_port}]: " input
    conn_port=${input:-$conn_port}
    
    echo ""
    echo "【可选配置】(直接回车跳过)"
    echo ""
    
    read -p "日志级别 DEBUG/INFO/WARNING/ERROR [默认: ${log_level}]: " input
    log_level=${input:-$log_level}
    
    read -p "触发符号 [默认: ${reminder}]: " input
    reminder=${input:-$reminder}
    
    read -p "机器人标语 [默认: ${slogan}]: " input
    slogan=${input:-$slogan}
    
    # 默认值
    default_mode="chat"
    
    echo ""
    read -p "是否配置 AI 聊天功能 (API Keys)? (1=是, 0=否): " api_choice
    if [ "$api_choice" = "1" ]; then
        echo ""
        echo "请选择 AI 模型："
        echo "  1. DeepSeek (Ds)"
        echo "  2. Google Gemini (Pixmap - 读图)"
        echo "  3. ChatGPT-4 (Net)"
        echo "  4. ChatGPT-3.5 (Normal)"
        read -p "请选择 [1-4]: " model_choice
        
        case $model_choice in
            1)
                default_mode="Ds"
                read -p "DeepSeek API Key: " deepseek_key
                ;;
            2)
                default_mode="Pixmap"
                read -p "Gemini API Key: " gemini_key
                ;;
            3)
                default_mode="Net"
                read -p "OpenAI API Key (ChatGPT-4): " openai_key
                ;;
            4)
                default_mode="Normal"
                read -p "OpenAI API Key (ChatGPT-3.5): " openai_key
                ;;
            *)
                echo "无效选择，默认使用 DeepSeek"
                default_mode="Ds"
                read -p "DeepSeek API Key: " deepseek_key
                ;;
        esac
    fi
    
    echo ""
    read -p "是否配置黑名单/静默群/自动审批? (1=是, 0=否): " list_choice
    if [ "$list_choice" = "1" ]; then
        read -p "黑名单 QQ 号 (用空格分隔): " black_list_input
        read -p "静默群号 (用空格分隔): " silents_input
        read -p "自动审批答案 (用空格分隔): " auto_approval_input
    fi
    
    echo ""
    read -p "是否配置定时回复? (1=是, 0=否): " timing_choice
    if [ "$timing_choice" = "1" ]; then
        read -p "使用默认模板还是自定义? (1=默认模板, 2=自定义): " timing_mode
        if [ "$timing_mode" = "1" ]; then
            cat > timing_message.ini << 'TIMING_EOF'
08:00⊕早上好！新的一天开始啦，一起加油吧 (ง •̀_•́)ง
11:45⊕各位 这个点也该吃了吧？(♡>𖥦<)/♥
22:00⊕该睡觉啦！晚安 🌙
TIMING_EOF
            echo "[成功] 定时回复配置完成 (使用默认模板)"
        else
            > timing_message.ini
            while true; do
                read -p "请输入发送时间 (格式: HH:MM，例如: 08:00): " timing_time
                if [ -z "$timing_time" ]; then
                    echo "时间不能为空！"
                    continue
                fi
                read -p "请输入发送内容: " timing_msg
                if [ -z "$timing_msg" ]; then
                    echo "内容不能为空！"
                    continue
                fi
                echo "${timing_time}⊕${timing_msg}" >> timing_message.ini
                echo "[成功] 定时任务已添加"
                read -p "是否继续创建定时任务? (1=是, 0=否): " continue_timing
                if [ "$continue_timing" != "1" ]; then
                    break
                fi
            done
            echo "[成功] 定时回复配置完成"
        fi
    fi
    
    # 更新配置文件
    python3 << PYTHON_SCRIPT
import json

with open('config.json', 'r', encoding='utf-8') as f:
    config = json.load(f)

config['owner'] = [$bot_qq]
config['uin'] = int($bot_uin)
config['Others']['bot_name'] = '$bot_name_cn'
config['Others']['bot_name_en'] = '$bot_name_en'
config['Others']['ROOT_User'] = [$owner_qq]
config['Connection']['host'] = '$conn_host'
config['Connection']['port'] = int($conn_port)
config['Log_level'] = '$log_level'
config['Others']['reminder'] = '$reminder'
config['Others']['slogan'] = '$slogan'

if '$gemini_key':
    config['Others']['gemini_key'] = '$gemini_key'
if '$openai_key':
    config['Others']['openai_key'] = '$openai_key'
if '$deepseek_key':
    config['Others']['deepseek_key'] = '$deepseek_key'

if '$black_list_input':
    config['black_list'] = [int(x) for x in '$black_list_input'.split()]
if '$silents_input':
    config['silents'] = [int(x) for x in '$silents_input'.split()]
if '$auto_approval_input':
    config['Others']['Auto_approval'] = '$auto_approval_input'.split()

config['Others']['default_mode'] = '$default_mode'
config['Connection']['host'] = '$conn_host'
config['Connection']['port'] = int($conn_port)

with open('config.json', 'w', encoding='utf-8') as f:
    json.dump(config, f, ensure_ascii=False, indent=2)

print("[成功] config.json 已更新")
PYTHON_SCRIPT
    
    echo ""
    echo "[成功] 配置完成！"
    echo ""
    cd ~
    return 0
}

# 配置 NapCat 函数
configure_napcat() {
    echo "==================================="
    echo "    配置 NapCat WS Server"
    echo "==================================="
    echo ""
    
    if [ ! -d "Napcat/opt/QQ/resources/app/app_launcher/napcat/config" ]; then
        echo "[错误] 未找到 NapCat 配置目录"
        echo ""
        read -p "按回车继续..."
        return 1
    fi
    
    if [ ! -d "Jianer_QQ_bot" ]; then
        echo "[错误] 未找到 Jianer_QQ_bot 目录"
        echo ""
        read -p "按回车继续..."
        return 1
    fi
    
    echo "正在读取 Jianer 配置..."
    bot_uin=$(python3 -c "import json; f=open('Jianer_QQ_bot/config.json'); d=json.load(f); print(d.get('uin', ''))" 2>/dev/null)
    conn_host=$(python3 -c "import json; f=open('Jianer_QQ_bot/config.json'); d=json.load(f); print(d.get('Connection', {}).get('host', '127.0.0.1'))" 2>/dev/null)
    conn_port=$(python3 -c "import json; f=open('Jianer_QQ_bot/config.json'); d=json.load(f); print(d.get('Connection', {}).get('port', 5004))" 2>/dev/null)
    
    if [ -z "$bot_uin" ]; then
        echo "[错误] 无法从 Jianer 配置中获取 QQ 号"
        echo ""
        read -p "按回车继续..."
        return 1
    fi
    
    echo "检测到 QQ 号: $bot_uin"
    echo "检测到监听地址: $conn_host"
    echo "检测到监听端口: $conn_port"
    echo ""
    
    napcat_config="Napcat/opt/QQ/resources/app/app_launcher/napcat/config/onebot11_${bot_uin}.json"
    
    python3 << PYTHON_SCRIPT
import json

config_file = "$napcat_config"

with open(config_file, 'r', encoding='utf-8') as f:
    config = json.load(f)

found = False
for server in config['network']['websocketServers']:
    if server.get('name') == 'Jianer':
        server['enable'] = True
        server['host'] = '$conn_host'
        server['port'] = int($conn_port)
        server['token'] = ''
        found = True
        break

if not found:
    new_server = {
        "enable": True,
        "name": "Jianer",
        "host": "$conn_host",
        "port": int($conn_port),
        "reportSelfMessage": False,
        "enableForcePushEvent": True,
        "messagePostFormat": "array",
        "token": "",
        "debug": False,
        "heartInterval": 30000
    }
    config['network']['websocketServers'].append(new_server)

with open(config_file, 'w', encoding='utf-8') as f:
    json.dump(config, f, ensure_ascii=False, indent=2)

print("[成功] NapCat WS Server 配置成功")
PYTHON_SCRIPT
    
    echo ""
    echo "==================================="
    echo "[成功] NapCat 配置完成！"
    echo ""
    echo "注意：请重启 NapCat 使配置生效"
    echo ""
    read -p "按回车继续..."
    return 0
}

# 后台启动 NapCat 函数
start_napcat_background() {
    echo "==================================="
    echo "    后台启动 NapCat"
    echo "==================================="
    echo ""
    
    screen -list | grep -q "napcat"
    if [ $? -eq 0 ]; then
        echo "检测到 NapCat 已在后台运行"
        echo ""
        read -p "是否停止现有实例并重新启动？(1=是, 0=否): " restart_choice
        if [ "$restart_choice" = "1" ]; then
            echo "正在停止现有 NapCat 实例..."
            screen -XS napcat quit
            sleep 2
        else
            echo "取消启动"
            return 0
        fi
    fi
    
    while true; do
        read -p "请输入要启动的 QQ 号: " qq_number
        if [ -z "$qq_number" ]; then
            echo "QQ 号不能为空，请重新输入！"
        elif [[ ! $qq_number =~ ^[0-9]+$ ]]; then
            echo "QQ 号必须是数字，请重新输入！"
        else
            break
        fi
    done
    
    echo ""
    echo "正在后台启动 NapCat (QQ: $qq_number)..."
    echo ""
    
    screen -dmS napcat bash -c "xvfb-run -a /root/Napcat/opt/QQ/qq --no-sandbox -q $qq_number"
    
    sleep 3
    
    screen -list | grep -q "napcat"
    if [ $? -ne 0 ]; then
        echo "[错误] NapCat 启动失败"
        echo ""
        read -p "按回车继续..."
        return 1
    fi
    
    echo "[成功] NapCat 已在后台启动"
    echo ""

    while true; do
        read -p "您是否已完成扫码登录？(1=是, 0=否): " login_choice
        if [ "$login_choice" = "1" ]; then
            echo ""
            echo "[成功] 登录成功！"
            break
        elif [ "$login_choice" = "0" ]; then
            echo ""
            echo "进入 screen 会话，请扫描二维码登录..."
            echo "登录完成后按 Ctrl+A 然后按 D 返回本脚本..."
            sleep 2
            screen -r napcat
            echo ""
            echo "已返回主菜单"
            read -p "请确认是否已完成扫码登录？(1=是, 0=否): " login_choice
            if [ "$login_choice" = "1" ]; then
                echo ""
                echo "[成功] 登录成功！"
                break
            fi
        else
            echo "无效选项，请重新输入！"
        fi
    done
    return 0
}

# 安装 venv 函数
install_venv() {
    echo "==================================="
    echo "    安装 Python venv"
    echo "==================================="
    echo ""
    
    # 检查 python3 是否存在
    if ! command -v python3 &> /dev/null; then
        echo "[错误] 未检测到 python3"
        echo ""
        read -p "按回车继续..."
        return 1
    fi
    
    # 获取 Python 版本
    PYTHON_VERSION=$(python3 --version 2>&1 | grep -oP '(?<=Python )\d+\.\d+')
    
    if [ -z "$PYTHON_VERSION" ]; then
        echo "[错误] 无法检测 Python 版本"
        echo ""
        read -p "按回车继续..."
        return 1
    fi
    
    echo "检测到 Python 版本: $PYTHON_VERSION"
    echo ""
    
    # 尝试安装对应的 python-venv 包
    VENV_PACKAGE="python${PYTHON_VERSION}-venv"
    echo "尝试安装 $VENV_PACKAGE..."
    
    # 检查是否有 sudo 权限
    if command -v sudo &> /dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y $VENV_PACKAGE
    else
        apt-get update -y
        apt-get install -y $VENV_PACKAGE
    fi
    
    # 检查安装是否成功
    if python3 -m venv /tmp/test_venv_$$ &> /dev/null; then
        rm -rf /tmp/test_venv_$$ 2>/dev/null
        echo ""
        echo "[成功] $VENV_PACKAGE 安装成功"
    else
        echo ""
        echo "[错误] $VENV_PACKAGE 安装失败或仍不可用"
        echo "尝试安装通用包 python3-venv..."
        
        # 尝试安装通用包
        if command -v sudo &> /dev/null; then
            sudo apt-get update -y
            sudo apt-get install -y python3-venv
        else
            apt-get update -y
            apt-get install -y python3-venv
        fi
        
        if python3 -m venv /tmp/test_venv_$$ &> /dev/null; then
            rm -rf /tmp/test_venv_$$ 2>/dev/null
            echo ""
            echo "[成功] python3-venv 安装成功"
        else
            echo ""
            echo "[错误] venv 安装失败"
            echo "请手动安装: apt-get install python3-venv 或 apt-get install $VENV_PACKAGE"
            echo ""
            read -p "按回车继续..."
            return 1
        fi
    fi
    
    echo ""
    read -p "按回车继续..."
}

# 主循环
while true; do
    # 每次运行前检查依赖
    check_dependencies
    
    show_menu
    read -p "请输入选项 [0-11]: " choice
    echo ""
    
    case $choice in
        1)
            echo "开始安装 Jianer..."
            echo ""
            
            # 检测是否已有安装进度
            SKIP_DOWNLOAD=false
            SKIP_UNZIP=false
            if [ -f "Jianer_QQ_bot.zip" ]; then
                echo "检测到已下载的 Jianer_QQ_bot.zip"
                read -p "是否使用已下载的文件？(1=是, 0=否): " use_zip_choice
                if [ "$use_zip_choice" = "1" ]; then
                    SKIP_DOWNLOAD=true
                fi
            fi
            
            if [ -d "Jianer_QQ_bot" ] && [ "$(ls -A Jianer_QQ_bot)" ]; then
                echo "检测到已解压的 Jianer_QQ_bot 目录"
                read -p "是否跳过下载和解压，直接进入目录？(1=是, 0=否): " use_dir_choice
                if [ "$use_dir_choice" = "1" ]; then
                    SKIP_UNZIP=true
                    cd Jianer_QQ_bot
                    echo "已进入项目目录"
                    echo ""
                fi
            fi
            
            # 检查Python版本
            echo "正在检查 Python 版本..."
            if command -v python3 &> /dev/null; then
                echo "[成功] Python3 已安装"
            else
                echo "[错误] 未检测到 Python3"
                echo ""
                read -p "按回车继续..."
                continue
            fi
            
            # 检查Git版本
            echo "正在检查 Git 版本..."
            if command -v git &> /dev/null; then
                echo "[成功] Git 已安装"
            else
                echo "[错误] 未检测到 Git"
                echo ""
                read -p "按回车继续..."
                continue
            fi
            
            # 检查unzip工具
            echo "正在检查 unzip 工具..."
            if command -v unzip &> /dev/null; then
                echo "[成功] unzip 已安装"
            else
                echo "[错误] 未检测到 unzip"
                echo ""
                read -p "按回车继续..."
                continue
            fi
            
            echo ""
            echo "依赖检查完成！"
            echo ""
            
            # 如果已经跳过了解压，直接跳到后续安装步骤
            if [ "$SKIP_UNZIP" = true ]; then
                echo "跳过下载和解压步骤"
                echo ""
            else
                # 获取GitHub发行版列表
                echo "正在获取 Jianer 发行版列表..."
                echo ""
                RELEASES_JSON=$(curl -s "https://api.github.com/repos/SRInternet-Studio/Jianer_QQ_bot/releases?per_page=100")
                if [ $? -ne 0 ] || [ -z "$RELEASES_JSON" ]; then
                    echo "[错误] 获取发行版列表失败，请检查网络连接"
                    echo ""
                    read -p "按回车继续..."
                    continue
                fi
                
                # 解析发行版信息
                RELEASE_COUNT=$(echo "$RELEASES_JSON" | grep -o '"tag_name"' | wc -l)
                CURRENT_PAGE=0
                ITEMS_PER_PAGE=10
                
                while true; do
                    clear
                    echo "==================================="
                    echo "    Jianer 版本选择"
                    echo "    共 $RELEASE_COUNT 个版本"
                    echo "==================================="
                    echo ""
                    
                    START_INDEX=$((CURRENT_PAGE * ITEMS_PER_PAGE))
                    END_INDEX=$((START_INDEX + ITEMS_PER_PAGE - 1))
                    
                    if [ $END_INDEX -ge $RELEASE_COUNT ]; then
                        END_INDEX=$((RELEASE_COUNT - 1))
                    fi
                    
                    for i in $(seq $START_INDEX $END_INDEX); do
                        INDEX=$((i + 1))
                        RELEASE_INFO=$(echo "$RELEASES_JSON" | python3 -c "import sys, json; data=json.load(sys.stdin); releases=[r for r in data if not r.get('draft', False)]; print(releases[$i]['name'] if len(releases)>$i else '')" 2>/dev/null)
                        if [ -n "$RELEASE_INFO" ]; then
                            echo "$INDEX. $RELEASE_INFO"
                        fi
                    done
                    
                    echo ""
                    echo "11. 上一页"
                    echo "12. 下一页"
                    echo "0. 返回"
                    echo ""
                    read -p "请选择要安装的版本 [0-12]: " version_choice
                    
                    case $version_choice in
                        0)
                            echo "返回主菜单..."
                            echo ""
                            break 2
                            ;;
                        11)
                            if [ $CURRENT_PAGE -gt 0 ]; then
                                CURRENT_PAGE=$((CURRENT_PAGE - 1))
                            else
                                echo "已经是第一页了"
                                sleep 1
                            fi
                            ;;
                        12)
                            if [ $((CURRENT_PAGE + 1)) * $ITEMS_PER_PAGE -lt $RELEASE_COUNT ]; then
                                CURRENT_PAGE=$((CURRENT_PAGE + 1))
                            else
                                echo "已经是最后一页了"
                                sleep 1
                            fi
                            ;;
                        [1-9]|10)
                            SELECTED_INDEX=$((version_choice - 1))
                            if [ $SELECTED_INDEX -ge 0 ] && [ $SELECTED_INDEX -lt $RELEASE_COUNT ]; then
                                # 获取选中的版本信息
                                SELECTED_RELEASE=$(echo "$RELEASES_JSON" | python3 -c "import sys, json; data=json.load(sys.stdin); releases=[r for r in data if not r.get('draft', False)]; print(json.dumps(releases[$SELECTED_INDEX]))" 2>/dev/null)
                                if [ -n "$SELECTED_RELEASE" ]; then
                                    TAG_NAME=$(echo "$SELECTED_RELEASE" | python3 -c "import sys, json; print(json.load(sys.stdin)['tag_name'])" 2>/dev/null)
                                    RELEASE_BODY=$(echo "$SELECTED_RELEASE" | python3 -c "import sys, json; import json as js; data=js.load(sys.stdin); print(data.get('body', '暂无简介'))" 2>/dev/null)
                                    
                                    # 显示版本信息和简介
                                    clear
                                    echo "==================================="
                                    echo "    版本信息"
                                    echo "==================================="
                                    echo ""
                                    echo "版本: $TAG_NAME"
                                    echo ""
                                    echo "简介:"
                                    echo "-----------------------------------"
                                    echo "$RELEASE_BODY"
                                    echo "-----------------------------------"
                                    echo ""
                                    
                                    # 询问是否确认安装
                                    read -p "是否确认安装此版本？(1=是, 0=否): " confirm_choice
                                    if [ "$confirm_choice" = "1" ]; then
                                        echo ""
                                    else
                                        echo "已取消安装，返回版本选择..."
                                        sleep 1
                                        continue 2
                                    fi
                                    
                                    # 从assets中获取Jianer_QQ_bot.zip的下载链接
                                    DOWNLOAD_URL=$(echo "$SELECTED_RELEASE" | python3 -c "import sys, json; import json as js; data=js.load(sys.stdin); assets=[a for a in data.get('assets', []) if a.get('name')=='Jianer_QQ_bot.zip']; print(assets[0]['browser_download_url'] if assets else '')" 2>/dev/null)

                                    if [ -z "$DOWNLOAD_URL" ]; then
                                        echo "[错误] 未找到 Jianer_QQ_bot.zip 文件"
                                        echo ""
                                        read -p "按回车继续..."
                                        continue 2
                                    fi

                                    echo ""
                                    echo "请选择下载镜像："
                                    echo "  1. GitHub 官方（直连）"
                                    echo "  2. 加速 1 - gh-proxy.org"
                                    echo "  3. 加速 2 - github.fufumc.top"
                                    echo "  4. 自动测速选择最快"
                                    echo ""
                                    read -p "请选择 [1-4]: " download_choice

                                    case $download_choice in
                                        1)
                                            FINAL_URL="$DOWNLOAD_URL"
                                            MIRROR_NAME="GitHub 官方"
                                            ;;
                                        2)
                                            FINAL_URL="https://gh-proxy.org/${DOWNLOAD_URL}"
                                            MIRROR_NAME="gh-proxy.org"
                                            ;;
                                        3)
                                            FINAL_URL="https://github.fufumc.top/${DOWNLOAD_URL}"
                                            MIRROR_NAME="github.fufumc.top"
                                            ;;
                                        4)
                                            echo ""
                                            echo "正在测速中，请稍候..."
                                            echo ""

                                            # 定义镜像列表
                                            mirrors=()
                                            mirrors+=("GitHub官方|$DOWNLOAD_URL")
                                            mirrors+=("gh-proxy.org|https://gh-proxy.org/${DOWNLOAD_URL}")
                                            mirrors+=("github.fufumc.top|https://github.fufumc.top/${DOWNLOAD_URL}")

                                            # 测速函数 - 使用秒数，不依赖 bc
                                            test_speed() {
                                                local name=$1
                                                local url=$2
                                                local start_time=$(date +%s)

                                                # 测试连接速度
                                                if curl -I --connect-timeout 3 --max-time 5 "$url" &>/dev/null; then
                                                    local end_time=$(date +%s)
                                                    local duration=$((end_time - start_time))
                                                    echo "$duration|$name"
                                                else
                                                    echo "999|$name"
                                                fi
                                            }

                                            # 测速并保存结果
                                            speeds=()
                                            for mirror in "${mirrors[@]}"; do
                                                IFS='|' read -r name url <<< "$mirror"
                                                result=$(test_speed "$name" "$url")
                                                speeds+=("$result")
                                            done

                                            # 找出最快的（最小的秒数）
                                            fastest_speed=999
                                            fastest_name=""
                                            fastest_url=""

                                            for speed_info in "${speeds[@]}"; do
                                                IFS='|' read -r speed name <<< "$speed_info"
                                                # 找到对应的 url
                                                for mirror in "${mirrors[@]}"; do
                                                    IFS='|' read -r m_name m_url <<< "$mirror"
                                                    if [ "$m_name" = "$name" ]; then
                                                        if [ "$speed" -lt "$fastest_speed" ]; then
                                                            fastest_speed=$speed
                                                            fastest_name=$name
                                                            fastest_url=$m_url
                                                        fi
                                                        break
                                                    fi
                                                done
                                            done

                                            FINAL_URL="$fastest_url"
                                            MIRROR_NAME="$fastest_name"

                                            echo "测速结果："
                                            for speed_info in "${speeds[@]}"; do
                                                IFS='|' read -r speed name <<< "$speed_info"
                                                echo "  $name: $speed 秒"
                                            done
                                            echo ""
                                            echo "已选择最快的镜像: $MIRROR_NAME"
                                            echo ""
                                            ;;
                                        *)
                                            echo "无效选项，使用默认镜像（ghproxy.com）"
                                            FINAL_URL="https://ghproxy.com/${DOWNLOAD_URL}"
                                            MIRROR_NAME="ghproxy.com"
                                            ;;
                                    esac

                                    echo ""
                                    echo "正在从 $MIRROR_NAME 下载..."

                                    # 下载Jianer_QQ_bot.zip
                                    if [ "$SKIP_DOWNLOAD" = false ]; then
                                        wget "$FINAL_URL" -O Jianer_QQ_bot.zip
                                        if [ $? -eq 0 ]; then
                                            echo ""
                                            echo "[成功] 下载成功"
                                        else
                                            echo "[错误] 从 $MIRROR_NAME 下载失败"
                                            echo ""
                                            read -p "是否尝试使用其他镜像下载？(1=是, 0=否): " retry_download
                                            if [ "$retry_download" = "1" ]; then
                                                echo ""
                                                echo "正在尝试备用镜像..."
                                                wget "$DOWNLOAD_URL" -O Jianer_QQ_bot.zip
                                                if [ $? -eq 0 ]; then
                                                    echo ""
                                                    echo "[成功] 下载成功"
                                                else
                                                    echo "[错误] 所有镜像下载失败"
                                                    echo ""
                                                    read -p "按回车继续..."
                                                    continue 2
                                                fi
                                            else
                                                echo ""
                                                read -p "按回车继续..."
                                                continue 2
                                            fi
                                        fi
                                    else
                                        echo "使用已下载的文件"
                                    fi
                                    
                                    # 解压
                                    echo "正在解压..."
                                    unzip -q Jianer_QQ_bot.zip
                                    rm Jianer_QQ_bot.zip
                                    
                                    # 检查是否解压成功
                                    if [ -d "Jianer_QQ_bot" ] && [ "$(ls -A Jianer_QQ_bot)" ]; then
                                        echo "[成功] 解压成功"
                                        
                                        # 检查是否存在嵌套的Jianer_QQ_bot文件夹
                                        INNER_JIANER_DIR="Jianer_QQ_bot/Jianer_QQ_bot"
                                        if [ -d "$INNER_JIANER_DIR" ]; then
                                            echo "检测到嵌套文件夹，正在处理..."
                                            mv Jianer_QQ_bot/* Jianer_QQ_bot/.* Jianer_QQ_bot/Jianer_QQ_bot/ 2>/dev/null
                                            rmdir Jianer_QQ_bot/Jianer_QQ_bot
                                            echo "[成功] 嵌套文件夹处理完成"
                                        fi
                                    else
                                        echo "[错误] 解压失败"
                                        echo ""
                                        read -p "按回车继续..."
                                        continue 2
                                    fi
                                    
                                    # 进入项目目录
                                    cd Jianer_QQ_bot
                                    echo "已进入项目目录"
                                    echo ""
                                    
                                    # 继续后续安装步骤
                                    break
                                else
                                    echo "[错误] 获取版本信息失败"
                                    echo ""
                                    read -p "按回车继续..."
                                    continue 2
                                fi
                            else
                                echo "无效选项"
                                sleep 1
                            fi
                            ;;
                        *)
                            echo "无效选项"
                            sleep 1
                            ;;
                    esac
                done
            fi
            
            # 继续后续安装步骤
            echo "准备继续安装步骤..."
            echo ""
            
            # 检查虚拟环境是否已存在
            if [ -d ".venv" ]; then
                echo "检测到已存在的虚拟环境"
                read -p "是否使用已有虚拟环境？(1=是, 0=否): " use_venv_choice
                if [ "$use_venv_choice" = "1" ]; then
                    echo "使用已有虚拟环境"
                else
                    echo "删除旧虚拟环境，创建新的..."
                    rm -rf .venv
                    echo "正在创建虚拟环境..."
                    python3 -m venv .venv
                    if [ $? -eq 0 ]; then
                        echo "[成功] 虚拟环境创建成功"
                    else
                        echo "[错误] 虚拟环境创建失败"
                        echo ""
                        read -p "按回车继续..."
                        cd ~
                        continue
                    fi
                fi
            else
                echo "正在创建虚拟环境..."
                python3 -m venv .venv
                if [ $? -eq 0 ]; then
                    echo "[成功] 虚拟环境创建成功"
                else
                    echo "[错误] 虚拟环境创建失败"
                    echo ""
                    read -p "按回车继续..."
                    cd ~
                    continue
                fi
            fi
            echo ""
            
            # 激活虚拟环境
            echo "正在激活虚拟环境..."
            source .venv/bin/activate
            echo "[成功] 虚拟环境已激活"
            echo ""
            
            # 检查是否已安装依赖
            if [ -f "requirements.txt" ]; then
                echo "检测到 requirements.txt 文件，开始安装依赖..."
                echo ""
                echo "请选择安装源："
                echo "  1. 直连 PyPI（官方源，速度可能较慢）"
                echo "  2. 阿里云镜像（国内推荐）"
                echo "  3. 清华大学镜像"
                echo "  4. 中科大镜像"
                echo ""
                read -p "请选择 [1-4]: " mirror_choice

                case $mirror_choice in
                    1)
                        PIP_MIRROR=""
                        MIRROR_NAME="PyPI 官方源"
                        ;;
                    2)
                        PIP_MIRROR="-i https://mirrors.aliyun.com/pypi/simple"
                        MIRROR_NAME="阿里云镜像"
                        ;;
                    3)
                        PIP_MIRROR="-i https://pypi.tuna.tsinghua.edu.cn/simple"
                        MIRROR_NAME="清华大学镜像"
                        ;;
                    4)
                        PIP_MIRROR="-i https://pypi.mirrors.ustc.edu.cn/simple"
                        MIRROR_NAME="中科大镜像"
                        ;;
                    *)
                        echo "无效选项，使用默认镜像源（阿里云）"
                        PIP_MIRROR="-i https://mirrors.aliyun.com/pypi/simple"
                        MIRROR_NAME="阿里云镜像"
                        ;;
                esac

                echo "使用 $MIRROR_NAME 安装依赖..."
                echo ""

                # 检测 uv 包管理器
                USE_UV=false
                if check_uv; then
                    echo "检测到 uv 包管理器"
                    read -p "是否使用 uv 安装依赖？(1=是, 0=否): " use_uv_choice
                    if [ "$use_uv_choice" = "1" ]; then
                        USE_UV=true
                        echo "正在使用 uv 安装依赖..."
                        uv pip install -r requirements.txt $PIP_MIRROR
                        uv pip install setuptools $PIP_MIRROR
                        if [ $? -eq 0 ]; then
                            echo "[成功] uv 依赖安装成功"
                        else
                            echo "[错误] uv 依赖安装失败，改用传统方式..."
                            USE_UV=false
                            pip install -r requirements.txt $PIP_MIRROR
                            pip install setuptools $PIP_MIRROR
                        fi
                    else
                        USE_UV=false
                    fi
                fi

                if [ "$USE_UV" = false ]; then
                    pip install -r requirements.txt $PIP_MIRROR
                    pip install setuptools $PIP_MIRROR
                fi

                if [ $? -eq 0 ]; then
                    echo "[成功] 依赖安装成功"
                else
                    echo "[错误] 依赖安装失败"
                    echo ""
                    read -p "按回车继续..."
                    cd ~
                    continue
                fi
            else
                echo "未找到 requirements.txt 文件"
            fi
            echo ""
            
            # 返回主目录后调用配置函数
            cd ~
            # 调用配置函数
            configure_jianer "full"
            
            # 保存 uv 配置
            if [ "$USE_UV" = true ]; then
                set_uv_enabled "." "true"
                echo "[成功] 已配置使用 uv 包管理器"
            else
                set_uv_enabled "." "false"
                echo "[成功] 已配置使用传统包管理器"
            fi
            
            echo "==================================="
            echo "[成功] Jianer 安装完成！"
            echo "==================================="
            echo ""
            echo "后续步骤："
            echo "1. 运行 NapCat 连接 QQ"
            echo "2. 启动 Jianer"
            echo ""
            cd ~
            read -p "按回车继续..."
            ;;
        2)
            echo "开始安装 NapCat..."
            echo ""
            cd ~
            wget https://nclatest.znin.net/NapNeko/NapCat-Installer/main/script/install.sh -O napcat.sh
            bash napcat.sh --docker n --cli n
            echo ""
            read -p "按回车继续..."
            ;;
        3)
            install_venv
            ;;
        4)
            configure_jianer "full"
            ;;
        5)
            configure_napcat
            ;;
        6)
            echo "后台启动 Jianer..."
            if [ ! -d "Jianer_QQ_bot" ]; then
                echo "✗ 未找到 Jianer_QQ_bot 目录"
                echo ""
                read -p "按回车继续..."
                continue
            fi
            cd Jianer_QQ_bot
            if is_uv_enabled "."; then
                echo "使用 uv 启动 Jianer..."
                screen -dmS jianer bash -c "uv run main.py"
            else
                echo "使用传统方式启动 Jianer..."
                screen -dmS jianer bash -c "source .venv/bin/activate && python main.py"
            fi
            sleep 2
            if screen -list | grep -q "jianer"; then
                echo "✓ Jianer 已在后台启动"
            else
                echo "✗ Jianer 启动失败"
            fi
            cd ~
            echo ""
            read -p "按回车继续..."
            ;;
        7)
            echo "终止 Jianer..."
            screen -XS jianer quit
            echo "✓ Jianer 已停止"
            echo ""
            read -p "按回车继续..."
            ;;
        8)
            start_napcat_background
            ;;
        9)
            echo "终止 NapCat..."
            screen -XS napcat quit
            echo "✓ NapCat 已停止"
            echo ""
            read -p "按回车继续..."
            ;;
        10)
            echo "查看 Jianer 日志..."
            if ! screen -list | grep -q "jianer"; then
                echo "✗ Jianer 未在运行"
                echo ""
                read -p "按回车继续..."
                continue
            fi
            echo ""
            echo "进入 screen 会话，按 Ctrl+A 然后按 D 返回主菜单..."
            sleep 2
            screen -r jianer
            ;;
        11)
            echo "查看 NapCat 日志..."
            if ! screen -list | grep -q "napcat"; then
                echo "✗ NapCat 未在运行"
                echo ""
                read -p "按回车继续..."
                continue
            fi
            echo ""
            echo "进入 screen 会话，按 Ctrl+A 然后按 D 返回主菜单..."
            sleep 2
            screen -r napcat
            ;;
        0)
            echo "退出脚本..."
            exit 0
            ;;
        *)
            echo "无效选项，请重新输入！"
            echo ""
            read -p "按回车继续..."
            ;;
    esac
done

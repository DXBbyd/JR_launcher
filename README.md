# Jianer-QQ-Bot Launcher

一个简单、迅速、便捷的 Jianer QQ 机器人和 NapCat 的启动器脚本。

> by RBfrom

## 功能特性

- 一键安装 Jianer QQ 机器人
- 一键安装 NapCat
- 自动检测和安装依赖
- 支持后台运行
- 实时查看日志
- 便捷的配置管理

## 系统要求

- Linux 系统（已测试：Termux/Debian/Ubuntu）
- Python 10.0+
- Git
- Screen（用于后台运行）
- wget、curl、unzip

## 快速开始

### 1.手动下载发行版
 手动从仓库下载脚本，放置在/root目录下
```bash 运行脚本
  bash JR_Launcher.sh
```
### 2.通过服务器下载，并运行
```bash
curl -L -O "https://RBfrom.havugu.cn/Download/JR_Launcher.sh" && bash JR_Launcher.sh
```
# 26/2/27 更新说明
### 更新
 - 脚本已经拆分避免维护出错
### 修复
 - 修复了在26/2/26晚更新的Jianer NEXT3.1部署的问题
# 26/2/26更新说明
本次更新优化脚本使用体验
 - 下载Jianer压缩包添加镜像站选择，自动测速
 - 在安装项目依赖时，可以选择直连或者镜像站
### 修复
 - 解决了在用户准备扫码登陆的时候出现二维码或者其他字体是乱码的问题
### 3. 菜单选项说明

| 选项 | 功能 | 说明 |
|------|------|------|
| **【安装】** | | |
| 1 | 安装 Jianer | 从 GitHub 下载并安装 Jianer QQ 机器人 |
| 2 | 安装 NapCat | 安装 NapCat QQ 客户端 |
| 3 | 安装 venv | 安装 Python 虚拟环境支持 |
| **【配置】** | | |
| 4 | 配置 Jianer | 设置机器人 QQ、主人 QQ、AI API Key 等 |
| 5 | 配置 NapCat | 配置 NapCat WebSocket 服务器 |
| **【启动/停止】** | | |
| 6 | 后台启动 Jianer | 在后台启动 Jianer 机器人 |
| 7 | 终止 Jianer | 停止后台运行的 Jianer |
| 8 | 后台启动 NapCat | 在后台启动 NapCat |
| 9 | 终止 NapCat | 停止后台运行的 NapCat |
| **【日志】** | | |
| 10 | 查看 Jianer 日志 | 实时查看 Jianer 运行日志 |
| 11 | 查看 NapCat 日志 | 实时查看 NapCat 运行日志 |
| 0 | 退出脚本 | 退出启动器 |

## 完整使用流程

### 第一次使用

1. **运行脚本**
   ```bash
   bash JE_launcher.sh
   ```

2. **安装依赖**
   脚本会自动检测并提示安装缺少的依赖（screen、unzip、wget、curl、python3、git、python3-pip）

3. **安装 venv**（如果需要）
   选择菜单选项 `3` 安装 Python 虚拟环境支持

4. **安装 NapCat**
   选择菜单选项 `2` 安装 NapCat

5. **安装 Jianer**
   - 选择菜单选项 `1`
   - 选择要安装的版本
   - 等待下载和解压完成
   - 配置机器人参数（见下方配置说明）

6. **配置 NapCat**
   - 选择菜单选项 `5`
   - 脚本会自动读取 Jianer 配置并设置 NapCat

7. **启动服务**
   - 选择菜单选项 `8` 启动 NapCat
   - 扫码登录 QQ
   - 登录成功后，选择菜单选项 `6` 启动 Jianer

### 日常使用

1. 运行脚本：`bash JE_launcher.sh`
2. 查看服务状态（主菜单显示）
3. 如需查看日志，选择选项 `10` 或 `11`
4. 按 `q` 退出日志查看返回主菜单

## 配置说明

### Jianer 配置（选项 4）

#### 必须配置的参数
- **机器人 QQ 号**：你的机器人 QQ 号码
- **机器人中文名字**：绝对不能取名为“简儿！！！
- **机器人英文名字**: 自己取一个吧
- **主人 QQ 号**：拥有最高权限的 QQ 号

#### 连接配置
- **NapCat 运行地址**：默认 `127.0.0.1`
- **NapCat WebSocket 端口**：默认 `5004`

#### 可选配置
- **日志级别**：DEBUG/INFO/WARNING/ERROR
- **触发符号**：命令前缀，默认 `~`
- **机器人标语**：个性签名

#### AI 聊天功能
可选择以下 AI 模型：
1. DeepSeek（推荐）
2. Google Gemini（支持读图）
3. ChatGPT-4
4. ChatGPT-3.5

需要配置相应的 API Key。

#### 其他功能
- 黑名单 QQ 号
- 静默群号
- 自动审批答案
- 定时回复

## 项目链接

- [Jianer QQ Bot](https://github.com/SRInternet-Studio/Jianer_QQ_bot)
- [NapCat](https://github.com/NapNeko/NapCat-Installer)

## 注意事项

- 首次使用需要配置完整的机器人参数
- NapCat 需要扫码登录 QQ
- 建议使用 Screen 后台运行，避免终端关闭导致服务停止
- 定期检查日志排查问题

## 许可证

本项目遵循MIT许可证

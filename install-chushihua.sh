#!/bin/bash

# 定义进度条函数
show_progress() {
    local total=$1
    local current=$2
    local width=50
    local progress=$((current * width / total))
    local remaining=$((width - progress))
    echo -ne "\r["
    echo -ne "$(printf '#%.0s' $(seq 1 $progress))"
    echo -ne "$(printf ' %.0s' $(seq 1 $remaining))"
    echo -ne "] $current/$total"
}

# 定义时间显示函数
show_time() {
    local start_time=$1
    local end_time=$2
    local elapsed_time=$((end_time - start_time))
    local hours=$((elapsed_time / 3600))
    local minutes=$(( (elapsed_time % 3600) / 60 ))
    local seconds=$((elapsed_time % 60))
    echo "耗时: ${hours}小时 ${minutes}分钟 ${seconds}秒"
}

# 获取操作系统类型
get_os_type() {
    if [ -f /etc/redhat-release ]; then
        echo "RedHat"
    elif [ -f /etc/centos-release ]; then
        echo "CentOS"
    elif [ -f /etc/os-release ]; then
        . /etc/os-release
        echo "$ID"
    elif [ -f /etc/lsb-release ]; then
        . /etc/lsb-release
        echo "$DISTRIB_ID"
    else
        echo "Unknown"
    fi
}

# 替换为阿里源
replace_aliyun_sources() {
    echo "正在替换为阿里云源..."
    local os_type=$(get_os_type)
    local start_time=$(date +%s)
    case $os_type in
        "RedHat"|"CentOS")
            sudo cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.bak
            sudo curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-8.repo
            ;;
        "Ubuntu")
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
            sudo sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list
            ;;
        "Deepin"|"LinuxMint"|"Debian")
            sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
            sudo sed -i 's/deb.debian.org/mirrors.aliyun.com/g' /etc/apt/sources.list
            ;;
        *)
            echo "未知操作系统，无法替换源。"
            ;;
    esac
    local end_time=$(date +%s)
    show_time $start_time $end_time
    echo "替换阿里云源完成。"
}

# 关闭防火墙和SELinux
disable_firewall_and_selinux() {
    echo "正在关闭防火墙和SELinux..."
    local os_type=$(get_os_type)
    local start_time=$(date +%s)
    case $os_type in
        "RedHat"|"CentOS")
            sudo systemctl stop firewalld
            sudo systemctl disable firewalld
            sudo setenforce 0
            sudo sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
            ;;
        "Ubuntu")
            sudo ufw disable
            ;;
        *)
            echo "未知操作系统，无法关闭防火墙。"
            ;;
    esac
    local end_time=$(date +%s)
    show_time $start_time $end_time
    echo "防火墙和SELinux已关闭。"
}

# 更新操作系统和清理依赖
update_system() {
    echo "正在更新操作系统和清理依赖..."
    local os_type=$(get_os_type)
    local start_time=$(date +%s)
    case $os_type in
        "RedHat"|"CentOS")
            sudo dnf update -y
            sudo dnf autoremove -y
            ;;
        "Ubuntu")
            sudo apt update
            sudo apt upgrade -y
            sudo apt autoremove -y
            ;;
        *)
            echo "未知操作系统，无法更新。"
            ;;
    esac
    local end_time=$(date +%s)
    show_time $start_time $end_time
    echo "操作系统更新完成。"
}

# 配置时区
configure_timezone() {
    echo "正在配置上海时区..."
    local os_type=$(get_os_type)
    local start_time=$(date +%s)
    case $os_type in
        "RedHat"|"CentOS")
            sudo timedatectl set-timezone Asia/Shanghai
            ;;
        "Ubuntu")
            sudo timedatectl set-timezone Asia/Shanghai
            ;;
        *)
            echo "未知操作系统，无法配置时区。"
            ;;
    esac
    local end_time=$(date +%s)
    show_time $start_time $end_time
    echo "时区已配置为上海。"
}

# 执行初始化配置
initialize_system() {
    local steps=("replace_aliyun_sources" "disable_firewall_and_selinux" "update_system" "configure_timezone")
    local total_steps=${#steps[@]}
    local current_step=0

    for step in "${steps[@]}"; do
        ((current_step++))
        echo "正在执行步骤 $current_step/$total_steps: $step"
        show_progress $total_steps $current_step
        $step
        echo "步骤 $step 执行完成。"
    done
}

# 主程序
initialize_system

echo "欢迎使用webb专用Linux初始化脚本～"

#!/bin/bash

# 定义通用选择函数
choose_option() {
    local options=("$@")  # 接收所有参数作为选项列表
    local selected=0      # 当前选中的选项索引
    local show=0
    echo "请使用上下箭头选择 (回车键确认):"

    # 显示菜单的函数
    show_menu() {
#        clear  # 清屏
        for i in "${!options[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                echo -e "> \033[32m${options[$i]}\033[0m"  # 绿色显示选中的选项
            else
                echo "  ${options[$i]}"
            fi
        done
    }

    # 读取按键的函数
    navigate_menu() {
        while true; do
            show_menu
            # 读取单个字符，不需要回车
            read -sn1 key

            # 检测箭头键
            if [[ $key == $'\x1b' ]]; then
                read -sn2 -t 0.1 key  # 读取接下来的两个字符，检测方向
                if [[ $key == "[A" ]]; then
                    # 上箭头键
                    ((selected--))
                    if [ "$selected" -lt 0 ]; then
                        selected=$((${#options[@]} - 1))
                    fi
                elif [[ $key == "[B" ]]; then
                    # 下箭头键
                    ((selected++))
                    if [ "$selected" -ge "${#options[@]}" ]; then
                        selected=0
                    fi
                fi
            elif [[ $key == "" ]]; then
                # 检测回车键
                break
            fi

            for i in "${!options[@]}"; do
              if [ "$i" > 0 ]; then
                tput cuu 1
              fi
              tput el
            done
        done
    }
    # 执行菜单导航
    navigate_menu

    # 返回最终选择的选项
    choose_selected="${options[$selected]}"
}

# 调用选择菜单并直接输出结果
echo "请选择容器运行时："
choose_selected=
choose_option "CRI-O" "Containerd"

install_container_runtime="$choose_selected"
# 可以多次调用
# 比如选择操作系统
echo "请选择当前服务器角色："
choose_selected=
choose_option "Control" "Node"
install_role="$choose_selected"

./sys.sh

if [ "$install_container_runtime" -eq "CRI-O" ]; then
  ./cri-o.sh
else
  ./containerd.sh
fi

if [ "$install_role" -eq "Control" ]; then
  ./control.sh
else
  ./sub.sh
fi
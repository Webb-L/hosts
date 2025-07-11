#!/bin/bash

# 检查是否以root权限运行安装应用文件
if [[ $EUID -ne 0 ]]; then
   echo "需要root权限安装应用文件"
   echo "请使用: sudo ./install-user-service.sh"
   exit 1
fi

# 创建应用目录
mkdir -p /opt/hosts-manager

# 复制应用文件
cp -r build/linux/x64/release/bundle/* /opt/hosts-manager/

# 设置权限
chmod +x /opt/hosts-manager/hosts-manager

# 切换到普通用户安装用户服务
REAL_USER=${SUDO_USER:-$USER}
REAL_HOME=$(eval echo ~$REAL_USER)

# 创建用户systemd目录
sudo -u $REAL_USER mkdir -p $REAL_HOME/.config/systemd/user

# 复制用户服务文件
sudo -u $REAL_USER cp hosts-manager-user.service $REAL_HOME/.config/systemd/user/hosts-manager.service

# 重新加载用户systemd
sudo -u $REAL_USER systemctl --user daemon-reload

# 启用用户服务
sudo -u $REAL_USER systemctl --user enable hosts-manager.service

echo "用户服务安装完成！"
echo "启动服务: systemctl --user start hosts-manager"
echo "查看状态: systemctl --user status hosts-manager"
echo "停止服务: systemctl --user stop hosts-manager"
echo "开机自启: loginctl enable-linger $REAL_USER"
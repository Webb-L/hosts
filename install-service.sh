#!/bin/bash

# 检查是否以root权限运行
if [[ $EUID -ne 0 ]]; then
   echo "此脚本需要以root权限运行"
   echo "请使用: sudo ./install-service.sh"
   exit 1
fi

# 创建应用目录
mkdir -p /opt/hosts-manager

# 复制应用文件
cp -r build/linux/x64/release/bundle/* /opt/hosts-manager/

# 设置权限
chmod +x /opt/hosts-manager/hosts-manager

# 复制服务文件
cp hosts-manager.service /etc/systemd/system/

# 重新加载systemd
systemctl daemon-reload

# 启用服务
systemctl enable hosts-manager.service

echo "服务安装完成！"
echo "启动服务: sudo systemctl start hosts-manager"
echo "查看状态: sudo systemctl status hosts-manager"
echo "停止服务: sudo systemctl stop hosts-manager"
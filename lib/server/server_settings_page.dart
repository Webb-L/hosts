import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/server/server_manager.dart';
import 'package:hosts/widget/server_status_card.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// 服务器设置页面
class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final ServerManager _serverManager = ServerManager();

  bool _isLoading = true;
  Map<String, dynamic>? _serverStatus;
  List<Map<String, String>> _networkInterfaces = [];

  @override
  void initState() {
    super.initState();
    _loadServerSettings();
    _getNetworkInterfaces();
  }

  /// 加载服务器设置
  Future<void> _loadServerSettings() async {
    try {
      final status = await _serverManager.getServerStatus();
      setState(() {
        _serverStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError(
          '${AppLocalizations.of(context)!.load_server_settings_failed}: $e');
    }
  }

  /// 获取所有网络接口
  Future<void> _getNetworkInterfaces() async {
    final List<Map<String, String>> networkList = [];
    final info = NetworkInfo();

    try {
      print('开始获取网络信息...');

      // 1. 使用 network_info_plus 获取WiFi信息
      try {
        final wifiIP = await info.getWifiIP();
        final wifiName = await info.getWifiName();
        final wifiBSSID = await info.getWifiBSSID();

        print('WiFi IP: $wifiIP');
        print('WiFi Name: $wifiName');
        print('WiFi BSSID: $wifiBSSID');

        if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != '0.0.0.0') {
          networkList.add({
            'name': 'WiFi',
            'address': wifiIP,
            'description':
                'WiFi${wifiName != null ? ' ($wifiName)' : ''} (IPv4) Private',
            'icon': Icons.wifi.codePoint.toString(),
            'type': 'ipv4',
            'isMain': 'true',
          });
        }
      } catch (e) {
        print('获取WiFi信息失败: $e');
      }

      // 2. 使用传统方法作为补充
      try {
        final interfaces = await NetworkInterface.list(
          includeLoopback: true,
          includeLinkLocal: false,
          type: InternetAddressType.any,
        );

        print('发现的系统网络接口数量: ${interfaces.length}');

        // 收集所有已知IP，避免重复
        final knownIPs = networkList.map((e) => e['address']).toSet();

        for (final interface in interfaces) {
          print('接口: ${interface.name}, 地址数量: ${interface.addresses.length}');

          if (interface.addresses.isNotEmpty) {
            for (final address in interface.addresses) {
              final ip = address.address;

              // 跳过已知的IP地址
              if (knownIPs.contains(ip)) {
                continue;
              }

              print('  地址: $ip, 类型: ${address.type}');

              // 根据接口类型和地址类型确定图标和描述
              String description;
              IconData icon;
              bool isMainInterface = false;

              // 更精确的接口识别
              final interfaceName = interface.name.toLowerCase();

              if (interfaceName.contains('lo') || interfaceName == 'loopback') {
                description = 'Loopback';
                icon = Icons.loop;
              } else if (interfaceName.contains('wlan') ||
                  interfaceName.contains('wifi') ||
                  interfaceName.contains('wi-fi') ||
                  interfaceName.startsWith('wl')) {
                description = 'WiFi (${interface.name})';
                icon = Icons.wifi;
                isMainInterface = true;
              } else if (interfaceName.contains('eth') ||
                  interfaceName.contains('en') ||
                  interfaceName.startsWith('enp') ||
                  interfaceName.startsWith('ens') ||
                  interfaceName.startsWith('eno')) {
                description = 'Ethernet (${interface.name})';
                icon = Icons.settings_ethernet;
                isMainInterface = true;
              } else if (interfaceName.contains('docker') ||
                  interfaceName.contains('br-') ||
                  interfaceName.startsWith('docker')) {
                description = 'Docker (${interface.name})';
                icon = Icons.developer_board;
              } else if (interfaceName.contains('vmnet') ||
                  interfaceName.contains('vbox') ||
                  interfaceName.contains('virtual')) {
                description = 'Virtual (${interface.name})';
                icon = Icons.computer;
              } else if (interfaceName.contains('tun') ||
                  interfaceName.contains('tap')) {
                description = 'VPN/Tunnel (${interface.name})';
                icon = Icons.vpn_key;
              } else {
                description = interface.name;
                icon = Icons.device_hub;
                // 如果是未知接口但有局域网IP，也标记为主要接口
                if (address.type == InternetAddressType.IPv4) {
                  if (ip.startsWith('192.168.') ||
                      ip.startsWith('10.') ||
                      ip.startsWith('172.')) {
                    isMainInterface = true;
                  }
                }
              }

              // 添加地址类型和网络范围标识
              if (address.type == InternetAddressType.IPv6) {
                description += ' (IPv6)';
                if (ip.startsWith('fe80')) {
                  description += ' Link-Local';
                }
              } else {
                description += ' (IPv4)';
                if (ip.startsWith('192.168.')) {
                  description += ' Private';
                  isMainInterface = true;
                } else if (ip.startsWith('10.')) {
                  description += ' Private';
                  isMainInterface = true;
                } else if (ip.startsWith('172.')) {
                  final second = int.tryParse(ip.split('.')[1]) ?? 0;
                  if (second >= 16 && second <= 31) {
                    description += ' Private';
                    isMainInterface = true;
                  }
                } else if (ip.startsWith('127.')) {
                  description += ' Loopback';
                } else {
                  description += ' Public';
                  isMainInterface = true;
                }
              }

              networkList.add({
                'name': interface.name,
                'address': ip,
                'description': description,
                'icon': icon.codePoint.toString(),
                'type':
                    address.type == InternetAddressType.IPv4 ? 'ipv4' : 'ipv6',
                'isMain': isMainInterface.toString(),
              });

              knownIPs.add(ip);
            }
          }
        }
      } catch (e) {
        print('获取系统网络接口失败: $e');
      }

      // 3. 如果都没有获取到，添加默认的localhost
      if (networkList.isEmpty) {
        networkList.add({
          'name': 'localhost',
          'address': '127.0.0.1',
          'description': 'Localhost (IPv4) Loopback',
          'icon': Icons.computer.codePoint.toString(),
          'type': 'ipv4',
          'isMain': 'false',
        });
      }

      // 按优先级排序：主要接口 > IPv4 > 接口名称
      networkList.sort((a, b) {
        final aIsMain = a['isMain'] == 'true';
        final bIsMain = b['isMain'] == 'true';

        if (aIsMain && !bIsMain) return -1;
        if (!aIsMain && bIsMain) return 1;

        final aIsIPv4 = a['type'] == 'ipv4';
        final bIsIPv4 = b['type'] == 'ipv4';

        if (aIsIPv4 && !bIsIPv4) return -1;
        if (!aIsIPv4 && bIsIPv4) return 1;

        return a['name']!.compareTo(b['name']!);
      });

      print('最终网络接口列表: ${networkList.length}');
      for (final interface in networkList) {
        print('  ${interface['description']}: ${interface['address']}');
      }

      setState(() {
        _networkInterfaces = networkList;
      });
    } catch (e) {
      print('获取网络接口失败: $e');
      // 最后的备用方案
      setState(() {
        _networkInterfaces = [
          {
            'name': 'localhost',
            'address': '127.0.0.1',
            'description': 'Localhost (IPv4) Loopback',
            'icon': Icons.computer.codePoint.toString(),
            'type': 'ipv4',
            'isMain': 'false',
          }
        ];
      });
    }
  }

  /// 启动服务器
  Future<void> _startServer(List<SimpleHostFile>? selectedHosts) async {
    if (selectedHosts == null || selectedHosts.isEmpty) {
      // 用户取消了选择或没有选择任何文件
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 提取文件名列表
      final allowedFileNames = selectedHosts.map((f) => f.fileName).toList();
      
      final success = await _serverManager.startServer(
        allowedHostFiles: allowedFileNames,
      );

      if (success) {
        await _loadServerSettings();
        _showSuccess(AppLocalizations.of(context)!.server_started);
      } else {
        _showError(AppLocalizations.of(context)!.operation_failed);
      }
    } catch (e) {
      _showError('${AppLocalizations.of(context)!.operation_failed}: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 停止服务器
  Future<void> _stopServer() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _serverManager.stopServer();
      await _loadServerSettings();
      _showSuccess(AppLocalizations.of(context)!.server_stopped_msg);
    } catch (e) {
      _showError('${AppLocalizations.of(context)!.operation_failed}: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }




  /// 显示成功消息
  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// 显示错误消息
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.remote_sync),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 服务器状态卡片
                  _buildStatusCard(),
                  const SizedBox(height: 16),

                  // API文档卡片
                  _buildApiDocsCard(),
                ],
              ),
            ),
    );
  }

  /// 构建状态卡片
  Widget _buildStatusCard() {
    return ServerStatusCard(
      serverStatus: _serverStatus,
      networkInterfaces: _networkInterfaces,
      onStartServer: _startServer,
      onStopServer: _stopServer,
    );
  }

  /// 构建API文档卡片
  Widget _buildApiDocsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.api_docs,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Text(
              '${AppLocalizations.of(context)!.api_endpoints}：',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildApiEndpoint(
                'GET', '/', AppLocalizations.of(context)!.server_status),
            _buildApiEndpoint('GET', '/api/hosts',
                AppLocalizations.of(context)!.get_all_hosts_files),
            _buildApiEndpoint('GET', '/api/hosts/{fileName}',
                AppLocalizations.of(context)!.get_specific_hosts_file),
            _buildApiEndpoint('GET', '/api/hosts/{fileName}/history',
                AppLocalizations.of(context)!.get_hosts_file_history),
            _buildApiEndpoint(
                'GET',
                '/api/hosts/{fileName}/history/{historyId}',
                AppLocalizations.of(context)!.get_specific_history_content),
          ],
        ),
      ),
    );
  }

  /// 构建API端点项
  Widget _buildApiEndpoint(String method, String path, String description) {
    Color methodColor;
    switch (method) {
      case 'GET':
        methodColor = Theme.of(context).colorScheme.primary;
        break;
      case 'POST':
        methodColor = Theme.of(context).colorScheme.secondary;
        break;
      case 'PUT':
        methodColor = Theme.of(context).colorScheme.tertiary;
        break;
      case 'DELETE':
        methodColor = Theme.of(context).colorScheme.error;
        break;
      default:
        methodColor = Theme.of(context).colorScheme.outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: methodColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              method,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  path,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:hosts/server/bloc/server_settings_event.dart';
import 'package:hosts/server/bloc/server_settings_state.dart';
import 'package:hosts/server/server_manager.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// 服务器设置页面 BLoC
class ServerSettingsBloc extends Bloc<ServerSettingsEvent, ServerSettingsState> {
  ServerSettingsBloc() : super(const ServerSettingsState()) {
    on<LoadServerSettings>(_onLoadServerSettings);
    on<LoadNetworkInterfaces>(_onLoadNetworkInterfaces);
    on<ToggleServerStatus>(_onToggleServerStatus);
    on<RefreshServerStatus>(_onRefreshServerStatus);
  }

  final ServerManager _serverManager = ServerManager();

  /// 加载服务器设置
  Future<void> _onLoadServerSettings(
    LoadServerSettings event,
    Emitter<ServerSettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      
      final status = await _serverManager.getServerStatus();
      
      emit(state.copyWith(
        isLoading: false,
        serverStatus: status,
        isServerEnabled: status['isEnabled'] ?? false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: '加载服务器设置失败: $e',
      ));
    }
  }

  /// 加载网络接口
  Future<void> _onLoadNetworkInterfaces(
    LoadNetworkInterfaces event,
    Emitter<ServerSettingsState> emit,
  ) async {
    try {
      final networkInterfaces = await _getNetworkInterfaces();
      emit(state.copyWith(networkInterfaces: networkInterfaces));
    } catch (e) {
      emit(state.copyWith(
        errorMessage: '获取网络接口失败: $e',
      ));
    }
  }

  /// 切换服务器状态
  Future<void> _onToggleServerStatus(
    ToggleServerStatus event,
    Emitter<ServerSettingsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));

      bool success;
      if (state.isServerEnabled) {
        await _serverManager.stopServer();
        success = true;
      } else {
        success = await _serverManager.startServer();
      }

      if (success) {
        // 重新加载服务器状态
        final status = await _serverManager.getServerStatus();
        emit(state.copyWith(
          isLoading: false,
          serverStatus: status,
          isServerEnabled: status['isEnabled'] ?? false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: '操作失败',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: '操作失败: $e',
      ));
    }
  }

  /// 刷新服务器状态
  Future<void> _onRefreshServerStatus(
    RefreshServerStatus event,
    Emitter<ServerSettingsState> emit,
  ) async {
    add(LoadServerSettings());
  }

  /// 获取所有网络接口
  Future<List<Map<String, String>>> _getNetworkInterfaces() async {
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

      return networkList;
    } catch (e) {
      print('获取网络接口失败: $e');
      // 最后的备用方案
      return [
        {
          'name': 'localhost',
          'address': '127.0.0.1',
          'description': 'Localhost (IPv4) Loopback',
          'icon': Icons.computer.codePoint.toString(),
          'type': 'ipv4',
          'isMain': 'false',
        }
      ];
    }
  }
}
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hosts/utils/device_api_cache.dart';

/// 附近设备扫描器
class NearbyDevicesScanner {
  static const int _defaultPort = 1204;
  static const Duration _scanTimeout = Duration(seconds: 2);
  
  // SharedPreferences键名
  static const String _deviceCacheKey = 'nearby_devices_cache';
  static const String _priorityIPsKey = 'priority_ips_cache';
  
  // 设备缓存，记录之前扫描到的设备
  static final Map<String, NearbyDevice> _deviceCache = {};
  
  // 设备优先级列表，之前扫描到的设备优先扫描
  static final List<String> _priorityIPs = [];
  
  // 是否已初始化（加载缓存）
  static bool _isInitialized = false;

  /// 实时扫描附近设备，发现设备时立即回调
  static Future<void> scanNearbyDevicesRealTime({
    required Function(NearbyDevice) onDeviceFound,
  }) async {
    try {
      // 确保缓存已初始化
      await _initializeCache();
      
      print('开始实时扫描附近设备...');
      
      // 获取当前设备的IP地址
      String? currentIP = await _getCurrentIP();
      
      if (currentIP == null || currentIP.isEmpty) {
        print('无法获取当前设备IP地址');
        return;
      }
      
      print('当前设备IP: $currentIP');
      
      // 解析IP地址段
      final ipParts = currentIP.split('.');
      if (ipParts.length != 4) {
        print('IP地址格式错误: $currentIP');
        return;
      }
      
      final baseIP = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';
      print('扫描网段: $baseIP.1-254');
      
      // 创建所有需要扫描的IP列表
      final List<String> ipsToScan = [];
      
      // 首先添加优先级IP（之前扫描到的设备）
      for (final ip in _priorityIPs) {
        if (ip.startsWith(baseIP) && ip != currentIP) {
          ipsToScan.add(ip);
        }
      }
      
      // 然后添加其他IP
      for (int i = 1; i <= 254; i++) {
        final targetIP = '$baseIP.$i';
        if (targetIP != currentIP && !ipsToScan.contains(targetIP)) {
          ipsToScan.add(targetIP);
        }
      }
      
      // 分批扫描，每批最多50个设备，避免过多并发连接
      const int batchSize = 50;
      for (int start = 0; start < ipsToScan.length; start += batchSize) {
        final int end = (start + batchSize).clamp(0, ipsToScan.length);
        final batch = ipsToScan.sublist(start, end);
        
        final List<Future<NearbyDevice?>> scanFutures = batch
            .map((ip) => _scanDevice(ip))
            .toList();
        
        // 使用 forEach 来处理每个完成的扫描结果
        for (final future in scanFutures) {
          future.then((device) async {
            if (device != null) {
              // 更新设备缓存
              _deviceCache[device.ip] = device;
              
              // 更新优先级列表
              if (!_priorityIPs.contains(device.ip)) {
                _priorityIPs.add(device.ip);
              }
              
              // 保存到持久存储
              await _saveCache();
              
              print('发现设备: ${device.ip}');
              onDeviceFound(device);
            }
          });
        }
        
        // 等待当前批次扫描完成
        await Future.wait(scanFutures);
      }
      
      print('实时扫描完成');
    } catch (e) {
      print('实时扫描附近设备失败: $e');
    }
  }

  /// 扫描附近设备（兼容性保留）
  static Future<List<NearbyDevice>> scanNearbyDevices() async {
    final List<NearbyDevice> devices = [];
    await scanNearbyDevicesRealTime(
      onDeviceFound: (device) => devices.add(device),
    );
    return devices;
  }
  
  /// 获取当前设备IP地址
  static Future<String?> _getCurrentIP() async {
    try {
      // 首先尝试获取WiFi IP
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      
      if (wifiIP != null && wifiIP.isNotEmpty && wifiIP != '0.0.0.0') {
        return wifiIP;
      }
      
      // 如果WiFi IP获取失败，尝试从网络接口获取
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );
      
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final ip = address.address;
          // 寻找私有网络地址
          if (ip.startsWith('192.168.') || 
              ip.startsWith('10.') || 
              (ip.startsWith('172.') && 
               int.tryParse(ip.split('.')[1]) != null && 
               int.parse(ip.split('.')[1]) >= 16 && 
               int.parse(ip.split('.')[1]) <= 31)) {
            return ip;
          }
        }
      }
      
      return null;
    } catch (e) {
      print('获取当前IP失败: $e');
      return null;
    }
  }
  
  /// 扫描单个设备
  static Future<NearbyDevice?> _scanDevice(String ip) async {
    try {
      // 尝试连接设备的共享端口
      final socket = await Socket.connect(ip, _defaultPort, timeout: _scanTimeout);
      await socket.close();
      
      // 连接成功，进一步验证是否是hosts服务器
      final bool isHostsServer = await _verifyHostsServer(ip);
      
      // 如果是hosts服务器，缓存API响应
      if (isHostsServer) {
        await DeviceApiCache.cacheDeviceAPIResponses(ip);
      }
      
      return NearbyDevice(
        ip: ip,
        isReachable: true,
        hasSharing: isHostsServer,
        lastSeen: DateTime.now(),
      );
    } catch (e) {
      // 连接失败，设备不可达或未开启共享
      return null;
    }
  }
  
  /// 验证是否是hosts服务器
  static Future<bool> _verifyHostsServer(String ip) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;
      
      final request = await httpClient.get(ip, _defaultPort, '/');
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        // 检查响应是否包含hosts服务器的特征
        if (responseBody.contains('status') && responseBody.contains('running')) {
          httpClient.close();
          return true;
        }
      }
      
      httpClient.close();
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查特定设备是否开启共享
  static Future<bool> checkDeviceSharing(String ip) async {
    try {
      final socket = await Socket.connect(ip, _defaultPort, timeout: _scanTimeout);
      await socket.close();
      return await _verifyHostsServer(ip);
    } catch (e) {
      return false;
    }
  }
  
  /// 测试本地服务器是否正在运行
  static Future<bool> testLocalServer() async {
    try {
      final currentIP = await _getCurrentIP();
      if (currentIP != null) {
        print('测试本地服务器: $currentIP:$_defaultPort');
        return await checkDeviceSharing(currentIP);
      }
      return false;
    } catch (e) {
      print('测试本地服务器失败: $e');
      return false;
    }
  }
  
  /// 初始化缓存（从持久存储加载）
  static Future<void> _initializeCache() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 加载设备缓存
      final deviceCacheJson = prefs.getString(_deviceCacheKey);
      if (deviceCacheJson != null) {
        final Map<String, dynamic> cacheData = jsonDecode(deviceCacheJson);
        _deviceCache.clear();
        cacheData.forEach((ip, deviceData) {
          _deviceCache[ip] = NearbyDevice.fromJson(deviceData);
        });
      }
      
      // 加载优先级IP列表
      final priorityIPs = prefs.getStringList(_priorityIPsKey);
      if (priorityIPs != null) {
        _priorityIPs.clear();
        _priorityIPs.addAll(priorityIPs);
      }
      
      _isInitialized = true;
      print('设备缓存初始化完成，加载了${_deviceCache.length}个设备');
    } catch (e) {
      print('加载设备缓存失败: $e');
      _isInitialized = true; // 即使失败也标记为已初始化，避免重复尝试
    }
  }
  
  /// 保存缓存到持久存储
  static Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // 保存设备缓存
      final Map<String, dynamic> cacheData = {};
      _deviceCache.forEach((ip, device) {
        cacheData[ip] = device.toJson();
      });
      await prefs.setString(_deviceCacheKey, jsonEncode(cacheData));
      
      // 保存优先级IP列表
      await prefs.setStringList(_priorityIPsKey, _priorityIPs);
      
      print('设备缓存已保存到存储');
    } catch (e) {
      print('保存设备缓存失败: $e');
    }
  }
  
  /// 获取缓存的设备列表
  static Future<List<NearbyDevice>> getCachedDevices() async {
    await _initializeCache();
    return _deviceCache.values.toList();
  }
  
  /// 检查缓存设备的在线状态
  static Future<void> checkCachedDevicesOnlineStatus() async {
    await _initializeCache();
    
    if (_deviceCache.isEmpty) return;
    
    print('开始检查${_deviceCache.length}个缓存设备的在线状态...');
    
    final List<String> offlineDevices = [];
    final List<Future<void>> checkFutures = [];
    
    for (final device in _deviceCache.values) {
      final future = _checkSingleDeviceOnlineStatus(device).then((isOnline) {
        if (isOnline) {
          // 设备在线，更新最后见到时间和在线状态
          final updatedDevice = device.copyWith(
            lastSeen: DateTime.now(),
            isOnline: true,
          );
          _deviceCache[device.ip] = updatedDevice;
        } else {
          // 设备离线，标记为离线
          final updatedDevice = device.copyWith(isOnline: false);
          _deviceCache[device.ip] = updatedDevice;
          
          // 检查是否长时间离线（超过7天），如果是则加入移除列表
          final daysSinceLastSeen = DateTime.now().difference(device.lastSeen).inDays;
          if (daysSinceLastSeen > 7) {
            offlineDevices.add(device.ip);
          }
        }
      });
      checkFutures.add(future);
    }
    
    // 等待所有检查完成
    await Future.wait(checkFutures);
    
    // 移除长时间离线的设备
    for (final ip in offlineDevices) {
      _deviceCache.remove(ip);
      _priorityIPs.remove(ip);
      print('移除长时间离线的设备: $ip');
    }
    
    // 保存更新后的缓存
    await _saveCache();
    
    print('设备在线状态检查完成，移除了${offlineDevices.length}个长时间离线的设备');
  }
  
  /// 检查单个设备的在线状态
  static Future<bool> _checkSingleDeviceOnlineStatus(NearbyDevice device) async {
    try {
      // 使用更短的超时时间进行快速检查
      const quickTimeout = Duration(milliseconds: 500);
      final socket = await Socket.connect(device.ip, _defaultPort, timeout: quickTimeout);
      await socket.close();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取在线的缓存设备列表
  static Future<List<NearbyDevice>> getOnlineCachedDevices() async {
    await _initializeCache();
    return _deviceCache.values.where((device) => device.isOnline).toList();
  }
  
  /// 获取离线的缓存设备列表
  static Future<List<NearbyDevice>> getOfflineCachedDevices() async {
    await _initializeCache();
    return _deviceCache.values.where((device) => !device.isOnline).toList();
  }
  
  
  
  
  
  
  
  
  
  /// 清除设备缓存
  static Future<void> clearCache() async {
    _deviceCache.clear();
    _priorityIPs.clear();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceCacheKey);
      await prefs.remove(_priorityIPsKey);
      
      // 清除API响应缓存
      await DeviceApiCache.clearDeviceAPICache();
      
      print('设备缓存已清除');
    } catch (e) {
      print('清除设备缓存失败: $e');
    }
  }
}

/// 附近设备信息
class NearbyDevice {
  final String ip;
  final bool isReachable;
  final bool hasSharing;
  final DateTime lastSeen;
  final bool isOnline; // 当前是否在线
  
  const NearbyDevice({
    required this.ip,
    required this.isReachable,
    required this.hasSharing,
    required this.lastSeen,
    this.isOnline = true, // 默认为在线
  });
  
  /// 从JSON创建NearbyDevice实例
  factory NearbyDevice.fromJson(Map<String, dynamic> json) {
    return NearbyDevice(
      ip: json['ip'] as String,
      isReachable: json['isReachable'] as bool,
      hasSharing: json['hasSharing'] as bool,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
      isOnline: json['isOnline'] as bool? ?? true, // 兼容旧数据
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'ip': ip,
      'isReachable': isReachable,
      'hasSharing': hasSharing,
      'lastSeen': lastSeen.toIso8601String(),
      'isOnline': isOnline,
    };
  }
  
  /// 创建一个更新在线状态的副本
  NearbyDevice copyWith({
    String? ip,
    bool? isReachable,
    bool? hasSharing,
    DateTime? lastSeen,
    bool? isOnline,
  }) {
    return NearbyDevice(
      ip: ip ?? this.ip,
      isReachable: isReachable ?? this.isReachable,
      hasSharing: hasSharing ?? this.hasSharing,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
    );
  }
  
  @override
  String toString() {
    return 'NearbyDevice(ip: $ip, isReachable: $isReachable, hasSharing: $hasSharing, lastSeen: $lastSeen, isOnline: $isOnline)';
  }
}
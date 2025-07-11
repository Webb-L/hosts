import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:network_info_plus/network_info_plus.dart';

/// 附近设备扫描器
class NearbyDevicesScanner {
  static const int _defaultPort = 1204;
  static const Duration _scanTimeout = Duration(seconds: 2);
  
  /// 扫描附近设备
  static Future<List<NearbyDevice>> scanNearbyDevices() async {
    try {
      print('开始扫描附近设备...');
      
      // 获取当前设备的IP地址
      String? currentIP = await _getCurrentIP();
      
      if (currentIP == null || currentIP.isEmpty) {
        print('无法获取当前设备IP地址');
        return [];
      }
      
      print('当前设备IP: $currentIP');
      
      // 解析IP地址段
      final ipParts = currentIP.split('.');
      if (ipParts.length != 4) {
        print('IP地址格式错误: $currentIP');
        return [];
      }
      
      final baseIP = '${ipParts[0]}.${ipParts[1]}.${ipParts[2]}';
      print('扫描网段: $baseIP.1-254');
      
      final List<NearbyDevice> devices = [];
      
      // 扫描同网段的设备，限制并发数量以避免过多连接
      const int batchSize = 50;
      for (int start = 1; start <= 254; start += batchSize) {
        final int end = (start + batchSize - 1).clamp(1, 254);
        final List<Future<NearbyDevice?>> scanFutures = [];
        
        for (int i = start; i <= end; i++) {
          final targetIP = '$baseIP.$i';
          // 跳过当前设备
          if (targetIP == currentIP) continue;
          
          scanFutures.add(_scanDevice(targetIP));
        }
        
        // 等待当前批次扫描完成
        final results = await Future.wait(scanFutures);
        
        // 过滤出有效设备
        for (final result in results) {
          if (result != null) {
            devices.add(result);
            print('发现设备: ${result.ip}');
          }
        }
      }
      
      print('扫描完成，发现${devices.length}个设备');
      return devices;
    } catch (e) {
      print('扫描附近设备失败: $e');
      return [];
    }
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
}

/// 附近设备信息
class NearbyDevice {
  final String ip;
  final bool isReachable;
  final bool hasSharing;
  final DateTime lastSeen;
  
  const NearbyDevice({
    required this.ip,
    required this.isReachable,
    required this.hasSharing,
    required this.lastSeen,
  });
  
  @override
  String toString() {
    return 'NearbyDevice(ip: $ip, isReachable: $isReachable, hasSharing: $hasSharing, lastSeen: $lastSeen)';
  }
}
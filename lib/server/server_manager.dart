import 'dart:async';
import 'package:hosts/server/hosts_server.dart';
import 'package:hosts/util/settings_manager.dart';

/// 服务器管理器
/// 负责管理HTTP服务器的生命周期和配置
class ServerManager {
  static final ServerManager _instance = ServerManager._internal();
  factory ServerManager() => _instance;
  ServerManager._internal();
  
  final HostsServer _server = HostsServer();
  final SettingsManager _settingsManager = SettingsManager();
  
  // 配置键
  static const String _serverEnabledKey = 'server_enabled';
  static const String _serverPortKey = 'server_port';
  static const String _serverHostKey = 'server_host';
  static const String _serverAutoStartKey = 'server_auto_start';
  
  // 默认配置
  static const int _defaultPort = 1204;
  static const String _defaultHost = '0.0.0.0';
  
  /// 获取服务器实例
  HostsServer get server => _server;
  
  /// 检查服务器是否启用
  Future<bool> isServerEnabled() async {
    return await _settingsManager.getBool(_serverEnabledKey) ?? false;
  }
  
  /// 设置服务器启用状态
  Future<void> setServerEnabled(bool enabled) async {
    await _settingsManager.setBool(_serverEnabledKey, enabled);
  }
  
  /// 获取服务器端口
  Future<int> getServerPort() async {
    return await _settingsManager.getInt(_serverPortKey) ?? _defaultPort;
  }
  
  /// 设置服务器端口
  Future<void> setServerPort(int port) async {
    await _settingsManager.setInt(_serverPortKey, port);
  }
  
  /// 获取服务器主机
  Future<String> getServerHost() async {
    return await _settingsManager.getString(_serverHostKey) ?? _defaultHost;
  }
  
  /// 设置服务器主机
  Future<void> setServerHost(String host) async {
    await _settingsManager.setString(_serverHostKey, host);
  }
  
  /// 获取自动启动设置
  Future<bool> isAutoStartEnabled() async {
    return await _settingsManager.getBool(_serverAutoStartKey) ?? false;
  }
  
  /// 设置自动启动
  Future<void> setAutoStart(bool enabled) async {
    await _settingsManager.setBool(_serverAutoStartKey, enabled);
  }
  
  /// 初始化服务器管理器
  Future<void> initialize() async {
    // 如果启用了自动启动，则启动服务器
    if (await isAutoStartEnabled() && await isServerEnabled()) {
      await startServer();
    }
  }
  
  /// 启动服务器
  Future<bool> startServer() async {
    try {
      if (_server.isRunning) {
        return true;
      }
      
      final port = await getServerPort();
      final host = await getServerHost();
      
      await _server.start(port: port, host: host);
      await setServerEnabled(true);
      
      return true;
    } catch (e) {
      print('启动服务器失败: $e');
      return false;
    }
  }
  
  /// 停止服务器
  Future<void> stopServer() async {
    try {
      await _server.stop();
      await setServerEnabled(false);
    } catch (e) {
      print('停止服务器失败: $e');
    }
  }
  
  /// 重启服务器
  Future<bool> restartServer() async {
    try {
      await stopServer();
      return await startServer();
    } catch (e) {
      print('重启服务器失败: $e');
      return false;
    }
  }
  
  /// 获取服务器状态信息
  Future<Map<String, dynamic>> getServerStatus() async {
    return {
      'isRunning': _server.isRunning,
      'isEnabled': await isServerEnabled(),
      'port': await getServerPort(),
      'host': await getServerHost(),
      'autoStart': await isAutoStartEnabled(),
      'url': _server.serverUrl,
    };
  }
  
  /// 更新服务器配置
  Future<bool> updateServerConfig({
    int? port,
    String? host,
    bool? autoStart,
  }) async {
    try {
      bool needRestart = false;
      
      if (port != null) {
        final currentPort = await getServerPort();
        if (currentPort != port) {
          await setServerPort(port);
          needRestart = true;
        }
      }
      
      if (host != null) {
        final currentHost = await getServerHost();
        if (currentHost != host) {
          await setServerHost(host);
          needRestart = true;
        }
      }
      
      if (autoStart != null) {
        await setAutoStart(autoStart);
      }
      
      // 如果服务器正在运行且配置有变化，需要重启
      if (_server.isRunning && needRestart) {
        return await restartServer();
      }
      
      return true;
    } catch (e) {
      print('更新服务器配置失败: $e');
      return false;
    }
  }
  
  /// 验证端口是否可用
  Future<bool> isPortAvailable(int port) async {
    try {
      // 这里可以添加端口检查逻辑
      // 暂时返回true
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 清理资源
  Future<void> dispose() async {
    await stopServer();
  }
}
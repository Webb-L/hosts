import 'package:flutter_background/flutter_background.dart';

class BackgroundService {
  static bool _isRunning = false;
  
  static bool get isRunning => _isRunning;
  
  /// 启动后台服务
  static Future<bool> startBackgroundService() async {
    if (_isRunning) return true;
    
    try {
      final hasPermissions = await FlutterBackground.hasPermissions;
      if (!hasPermissions) {
        return false;
      }
      
      final success = await FlutterBackground.enableBackgroundExecution();
      if (success) {
        _isRunning = true;
      }
      return success;
    } catch (e) {
      print('启动后台服务失败: $e');
      return false;
    }
  }
  
  /// 停止后台服务
  static Future<bool> stopBackgroundService() async {
    if (!_isRunning) return true;
    
    try {
      final success = await FlutterBackground.disableBackgroundExecution();
      if (success) {
        _isRunning = false;
      }
      return success;
    } catch (e) {
      print('停止后台服务失败: $e');
      return false;
    }
  }
  
  /// 请求后台权限
  static Future<bool> requestPermissions() async {
    try {
      final hasPermissions = await FlutterBackground.hasPermissions;
      if (hasPermissions) return true;
      
      // 在Android上会自动请求权限
      return await FlutterBackground.hasPermissions;
    } catch (e) {
      print('请求后台权限失败: $e');
      return false;
    }
  }
}
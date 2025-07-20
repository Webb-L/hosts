import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// 设备API直接访问工具类
class DeviceApiCache {
  static const int _defaultPort = 1204;
  static const Duration _scanTimeout = Duration(seconds: 2);

  /// 获取设备API响应（直接访问，不缓存）
  static Future<List<Map<String, dynamic>>> getCachedDeviceData(String ip) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;

      final request = await httpClient.get(ip, _defaultPort, '/api/hosts');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        
        try {
          final responseData = jsonDecode(responseBody);
          if (responseData['success'] == true) {
            final List<dynamic> hostsList = responseData['data'];

            // 只返回fileName和remark字段
            final List<Map<String, dynamic>> filteredHostsList = hostsList
                .map((host) => {
                      'fileName': host['fileName'],
                      'remark': host['remark'] ?? '',
                    })
                .toList();

            httpClient.close();
            return filteredHostsList;
          }
        } catch (e) {
          print('解析hosts文件列表失败 $ip: $e');
        }
      }

      httpClient.close();
      return [];
    } catch (e) {
      print('获取设备数据失败 $ip: $e');
      return [];
    }
  }

  /// 获取特定hosts文件的内容（直接访问，不缓存）
  static Future<String?> getCachedHostsFileContent(String ip, String fileName) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;

      final request = await httpClient.get(ip, _defaultPort, '/api/hosts/$fileName');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        httpClient.close();
        return responseBody;
      }

      httpClient.close();
      return null;
    } catch (e) {
      print('获取hosts文件内容失败 $ip/$fileName: $e');
      return null;
    }
  }

  /// 获取特定hosts文件的历史记录列表（直接访问，不缓存）
  static Future<List<Map<String, dynamic>>> getCachedHostsFileHistory(String ip, String fileName) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;

      final request = await httpClient.get(ip, _defaultPort, '/api/hosts/$fileName/history');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        
        try {
          final responseData = jsonDecode(responseBody);
          if (responseData['success'] == true) {
            final List<dynamic> historyList = responseData['data'];
            httpClient.close();
            return historyList.map((item) => item as Map<String, dynamic>).toList();
          }
        } catch (e) {
          print('解析hosts文件历史失败 $ip/$fileName: $e');
        }
      }

      httpClient.close();
      return [];
    } catch (e) {
      print('获取hosts文件历史失败 $ip/$fileName: $e');
      return [];
    }
  }
}

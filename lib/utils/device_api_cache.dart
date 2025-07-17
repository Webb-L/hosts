import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// 设备API缓存工具类
class DeviceApiCache {
  static const int _defaultPort = 1204;
  static const Duration _scanTimeout = Duration(seconds: 2);

  /// 缓存设备API响应
  static Future<void> cacheDeviceAPIResponses(String ip) async {
    try {
      // 创建缓存目录
      final cacheDir = await _getCacheDirectoryForDevice(ip);
      await cacheDir.create(recursive: true);

      // 缓存hosts文件列表
      await _cacheHostsFilesList(ip, cacheDir);

      print('设备 $ip 的API响应已缓存');
    } catch (e) {
      print('缓存设备 $ip 的API响应失败: $e');
    }
  }

  /// 获取设备缓存目录
  static Future<Directory> _getCacheDirectoryForDevice(String ip) async {
    final appCacheDir = await getApplicationCacheDirectory();
    return Directory(path.join(appCacheDir.path, ip));
  }

  /// 缓存hosts文件列表
  static Future<void> _cacheHostsFilesList(
      String ip, Directory cacheDir) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;

      final request = await httpClient.get(ip, _defaultPort, '/api/hosts');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final hostsListFile = File(path.join(cacheDir.path, 'hosts_list'));

        // 解析响应并只保存fileName和remark字段
        try {
          final responseData = jsonDecode(responseBody);
          if (responseData['success'] == true) {
            final List<dynamic> hostsList = responseData['data'];

            // 只保存fileName和remark字段
            final List<Map<String, dynamic>> filteredHostsList = hostsList
                .map((host) => {
                      'fileName': host['fileName'],
                      'remark': host['remark'] ?? '',
                    })
                .toList();

            await hostsListFile.writeAsString(jsonEncode(filteredHostsList));
            print('hosts文件列表已缓存: $ip');

            // 进一步缓存每个文件的详细信息
            for (final hosts in hostsList) {
              final fileName = hosts['fileName'];
              if (fileName != null) {
                await _cacheHostsFileContent(ip, fileName, cacheDir);
                await _cacheHostsFileHistory(ip, fileName, cacheDir);
              }
            }
          }
        } catch (e) {
          print('解析hosts文件列表失败 $ip: $e');
        }
      }

      httpClient.close();
    } catch (e) {
      print('缓存hosts文件列表失败 $ip: $e');
    }
  }

  /// 缓存hosts文件内容
  static Future<void> _cacheHostsFileContent(
      String ip, String fileName, Directory cacheDir) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;

      final request =
          await httpClient.get(ip, _defaultPort, '/api/hosts/$fileName');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final fileDir = Directory(path.join(cacheDir.path, fileName));
        await fileDir.create(recursive: true);

        final hostsFile = File(path.join(fileDir.path, 'hosts'));
        await hostsFile.writeAsString(responseBody);
        print('hosts文件内容已缓存: $ip/$fileName');
      }

      httpClient.close();
    } catch (e) {
      print('缓存hosts文件内容失败 $ip/$fileName: $e');
    }
  }

  /// 缓存hosts文件历史
  static Future<void> _cacheHostsFileHistory(
      String ip, String fileName, Directory cacheDir) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;

      final request = await httpClient.get(
          ip, _defaultPort, '/api/hosts/$fileName/history');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final historyDir =
            Directory(path.join(cacheDir.path, fileName, 'history'));
        await historyDir.create(recursive: true);

        print('hosts文件历史已缓存: $ip/$fileName');

        // 缓存每个历史版本的内容
        try {
          final responseData = jsonDecode(responseBody);
          if (responseData['success'] == true) {
            final List<dynamic> historyList = responseData['data'];
            for (final historyItem in historyList) {
              final historyId = historyItem['id'];
              if (historyId != null) {
                await _cacheHostsFileHistoryContent(
                    ip, fileName, historyId, historyDir);
              }
            }
          }
        } catch (e) {
          print('解析hosts文件历史失败 $ip/$fileName: $e');
        }
      }

      httpClient.close();
    } catch (e) {
      print('缓存hosts文件历史失败 $ip/$fileName: $e');
    }
  }

  /// 缓存hosts文件历史内容
  static Future<void> _cacheHostsFileHistoryContent(String ip, String fileName,
      String historyId, Directory historyDir) async {
    try {
      final httpClient = HttpClient();
      httpClient.connectionTimeout = _scanTimeout;
      httpClient.idleTimeout = _scanTimeout;

      final request = await httpClient.get(
          ip, _defaultPort, '/api/hosts/$fileName/history/$historyId');
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final historyContentFile = File(path.join(historyDir.path, historyId));
        await historyContentFile.writeAsString(responseBody);
        print('hosts文件历史内容已缓存: $ip/$fileName/$historyId');
      }

      httpClient.close();
    } catch (e) {
      print('缓存hosts文件历史内容失败 $ip/$fileName/$historyId: $e');
    }
  }

  /// 获取缓存的设备API响应
  static Future<List<Map<String, dynamic>>> getCachedDeviceData(
      String ip) async {
    try {
      final cacheDir = await _getCacheDirectoryForDevice(ip);
      if (!await cacheDir.exists()) {
        return [];
      }

      List<Map<String, dynamic>> result = [];

      // 读取hosts文件列表
      final hostsListFile = File(path.join(cacheDir.path, 'hosts_list'));
      if (await hostsListFile.exists()) {
        result = (jsonDecode(hostsListFile.readAsStringSync()) as List<dynamic>)
            .map((it) => it as Map<String, dynamic>)
            .toList();
      }

      return result;
    } catch (e) {
      print('读取设备缓存数据失败 $ip: $e');
      return [];
    }
  }

  /// 获取特定hosts文件的缓存内容
  static Future<String?> getCachedHostsFileContent(
      String ip, String fileName) async {
    try {
      final cacheDir = await _getCacheDirectoryForDevice(ip);
      final hostsFile = File(path.join(cacheDir.path, fileName, 'hosts'));

      if (await hostsFile.exists()) {
        return await hostsFile.readAsString();
      }

      return null;
    } catch (e) {
      print('读取hosts文件缓存失败 $ip/$fileName: $e');
      return null;
    }
  }

  /// 获取特定hosts文件的历史版本内容
  static Future<String?> getCachedHostsFileHistoryContent(
      String ip, String fileName, String historyId) async {
    try {
      final cacheDir = await _getCacheDirectoryForDevice(ip);
      final historyFile =
          File(path.join(cacheDir.path, fileName, 'history', historyId));

      if (await historyFile.exists()) {
        return await historyFile.readAsString();
      }

      return null;
    } catch (e) {
      print('读取hosts文件历史缓存失败 $ip/$fileName/$historyId: $e');
      return null;
    }
  }

  /// 清除设备API缓存
  static Future<void> clearDeviceAPICache() async {
    try {
      final appSupportDir = await getApplicationSupportDirectory();
      final cacheDir = Directory(path.join(appSupportDir.path, 'cache'));

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('设备API缓存已清除');
      }
    } catch (e) {
      print('清除设备API缓存失败: $e');
    }
  }

  /// 清除特定设备的API缓存
  static Future<void> clearDeviceAPIResponseCache(String ip) async {
    try {
      final cacheDir = await _getCacheDirectoryForDevice(ip);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        print('设备 $ip 的API缓存已清除');
      }
    } catch (e) {
      print('清除设备 $ip 的API缓存失败: $e');
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

/// HTTP服务器管理类
/// 提供RESTful API来管理hosts文件
class HostsServer {
  static const int _defaultPort = 1204;
  static const String _defaultHost = '0.0.0.0';

  HttpServer? _server;
  final FileManager _fileManager = FileManager();

  final SettingsManager _settingsManager = SettingsManager();

  // 本地化字符串映射
  Map<String, String> _i18nStrings = {};

  // 允许访问的hosts文件列表
  List<String> _allowedHostFiles = [];

  int _port = _defaultPort;
  String _host = _defaultHost;

  /// 获取当前服务器端口
  int get port => _port;

  /// 获取当前服务器主机
  String get host => _host;

  /// 检查服务器是否正在运行
  bool get isRunning => _server != null;

  /// 获取服务器URL
  String get serverUrl => 'http://$_host:$_port';

  /// 设置本地化字符串
  void setI18nStrings(Map<String, String> strings) {
    _i18nStrings = strings;
  }

  /// 启动HTTP服务器
  /// [port] 端口号，默认1204
  /// [host] 主机地址，默认0.0.0.0
  /// [i18nStrings] 本地化字符串映射
  /// [allowedHostFiles] 允许访问的hosts文件列表
  Future<void> start(
      {int port = _defaultPort,
      String host = _defaultHost,
      Map<String, String>? i18nStrings,
      List<String>? allowedHostFiles}) async {
    if (_server != null) {
      throw Exception(_i18nStrings['server_already_running'] ??
          'Server is already running');
    }

    if (i18nStrings != null) {
      _i18nStrings = i18nStrings;
    }

    if (allowedHostFiles != null) {
      _allowedHostFiles = allowedHostFiles;
    }

    _port = port;
    _host = host;

    final router = _setupRouter();

    // 添加CORS中间件
    final handler = Pipeline()
        .addMiddleware(corsMiddleware())
        .addMiddleware(logRequests())
        .addHandler(router);

    try {
      _server = await shelf_io.serve(handler, _host, _port);
      print(
          '${_i18nStrings['http_server_start_success'] ?? 'HTTP server started successfully'}: ${serverUrl}');
    } catch (e) {
      print(
          '${_i18nStrings['http_server_start_failed'] ?? 'Failed to start HTTP server'}: $e');
      rethrow;
    }
  }

  /// 停止HTTP服务器
  Future<void> stop() async {
    if (_server != null) {
      await _server!.close();
      _server = null;
      print(_i18nStrings['http_server_stopped'] ?? 'HTTP server stopped');
    }
  }

  /// 重启HTTP服务器
  Future<void> restart() async {
    final currentPort = _port;
    final currentHost = _host;
    await stop();
    await start(port: currentPort, host: currentHost);
  }

  /// 设置路由
  Router _setupRouter() {
    final router = Router();

    // 根路径 - 服务器状态
    router.get('/', _handleStatus);

    // 获取所有hosts文件列表
    router.get('/api/hosts', _handleGetHosts);

    // 获取特定hosts文件内容
    router.get('/api/hosts/<fileName>', _handleGetHostFile);

    // 获取hosts文件的历史记录
    router.get('/api/hosts/<fileName>/history', _handleGetHostHistory);

    // 获取特定历史记录内容
    router.get(
        '/api/hosts/<fileName>/history/<historyId>', _handleGetHistoryContent);

    return router;
  }

  /// CORS中间件
  Middleware corsMiddleware() {
    return (Handler innerHandler) {
      return (Request request) async {
        if (request.method == 'OPTIONS') {
          return Response.ok('', headers: _corsHeaders);
        }

        final response = await innerHandler(request);
        return response.change(headers: _corsHeaders);
      };
    };
  }

  /// CORS头部
  Map<String, String> get _corsHeaders => {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization',
        'Content-Type': 'application/json; charset=utf-8',
      };

  /// 处理服务器状态请求
  Future<Response> _handleStatus(Request request) async {
    final status = {
      'status': 'running',
      'version': '1.0.0',
      'timestamp': DateTime.now().toIso8601String(),
      'endpoints': [
        'GET /api/hosts - ${_i18nStrings['get_all_hosts_files'] ?? 'Get all hosts files (JSON)'}',
        'GET /api/hosts/{fileName} - ${_i18nStrings['get_specific_hosts_file'] ?? 'Get specific hosts file content (plain text)'}',
        'GET /api/hosts/{fileName}/history - ${_i18nStrings['get_hosts_file_history'] ?? 'Get hosts file history (JSON)'}',
        'GET /api/hosts/{fileName}/history/{historyId} - ${_i18nStrings['get_specific_history_content'] ?? 'Get specific history content (plain text)'}',
      ]
    };

    return Response.ok(
      jsonEncode(status),
      headers: _corsHeaders,
    );
  }

  /// 处理获取所有hosts文件请求
  Future<Response> _handleGetHosts(Request request) async {
    try {
      List<dynamic> hostConfigs =
          await _settingsManager.getList(settingKeyHostConfigs);
      // 获取所有hosts文件列表
      final List<SimpleHostFile> hostFiles = [];

      for (Map<String, dynamic> config in hostConfigs) {
        SimpleHostFile hostFile = SimpleHostFile.fromJson(config);
        hostFiles.add(hostFile);
      }

      // 根据允许的hosts文件列表进行过滤
      final allowedHosts = hostFiles.where((hostFile) {
        // 如果没有设置允许列表，则返回所有文件
        if (_allowedHostFiles.isEmpty) {
          return true;
        }
        // 只返回允许访问的文件
        return _allowedHostFiles.contains(hostFile.fileName);
      }).toList();

      // 转换为API响应格式
      final hosts = allowedHosts
          .map((hostFile) => {
                'fileName': hostFile.fileName,
                'remark': hostFile.remark,
              })
          .toList();

      return Response.ok(
        jsonEncode({'success': true, 'data': hosts}),
        headers: _corsHeaders,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _corsHeaders,
      );
    }
  }

  /// 处理获取特定hosts文件请求
  Future<Response> _handleGetHostFile(Request request) async {
    final fileName = request.params['fileName'];
    if (fileName == null) {
      return Response.badRequest(
        body: _i18nStrings['missing_file_id'] ?? 'Missing file ID',
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    // 验证文件是否在允许访问的列表中
    if (_allowedHostFiles.isNotEmpty && !_allowedHostFiles.contains(fileName)) {
      return Response.forbidden(
        'Access denied: File not allowed',
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    try {
      final content = await _fileManager.readAsString(fileName);
      return Response.ok(
        content,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body:
            '${_i18nStrings['read_file_failed'] ?? 'Failed to read file'}: $e',
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }

  /// 处理获取hosts文件历史记录请求
  Future<Response> _handleGetHostHistory(Request request) async {
    final fileName = request.params['fileName'];
    if (fileName == null) {
      return Response.badRequest(
        body: jsonEncode({
          'success': false,
          'error': _i18nStrings['missing_file_id'] ?? 'Missing file ID'
        }),
        headers: _corsHeaders,
      );
    }

    // 验证文件是否在允许访问的列表中
    if (_allowedHostFiles.isNotEmpty && !_allowedHostFiles.contains(fileName)) {
      return Response.forbidden(
        jsonEncode({
          'success': false,
          'error': 'Access denied: File not allowed'
        }),
        headers: _corsHeaders,
      );
    }

    try {
      final historyList = await _fileManager.getHistory(fileName);

      // 转换为API响应格式
      final historyData = historyList
          .map((history) => {
                'id': history.fileName,
                'createTime': DateTime.fromMillisecondsSinceEpoch(
                        int.tryParse(history.fileName) ?? 0)
                    .toIso8601String(),
              })
          .toList();

      // 按时间倒序排列
      historyData.sort((a, b) =>
          b['timestamp'].toString().compareTo(a['timestamp'].toString()));

      return Response.ok(
        jsonEncode({'success': true, 'data': historyData}),
        headers: _corsHeaders,
      );
    } catch (e) {
      return Response.internalServerError(
        body: jsonEncode({'success': false, 'error': e.toString()}),
        headers: _corsHeaders,
      );
    }
  }

  /// 处理获取特定历史记录内容请求
  Future<Response> _handleGetHistoryContent(Request request) async {
    final fileName = request.params['fileName'];
    final historyId = request.params['historyId'];

    if (fileName == null || historyId == null) {
      return Response.badRequest(
        body: _i18nStrings['missing_file_id_or_history_id'] ??
            'Missing file ID or history ID',
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    // 验证文件是否在允许访问的列表中
    if (_allowedHostFiles.isNotEmpty && !_allowedHostFiles.contains(fileName)) {
      return Response.forbidden(
        'Access denied: File not allowed',
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }

    try {
      final historyList = await _fileManager.getHistory(fileName);
      final historyItem = historyList.firstWhere(
        (h) => h.fileName == historyId,
        orElse: () => throw Exception(
            _i18nStrings['history_not_found'] ?? 'History not found'),
      );

      final content = _fileManager.readHistoryFile(historyItem.path);

      return Response.ok(
        content,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    } catch (e) {
      return Response.internalServerError(
        body:
            '${_i18nStrings['read_history_failed'] ?? 'Failed to read history'}: $e',
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Access-Control-Allow-Origin': '*',
        },
      );
    }
  }
}

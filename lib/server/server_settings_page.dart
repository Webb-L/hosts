import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/server/server_manager.dart';

/// 服务器设置页面
class ServerSettingsPage extends StatefulWidget {
  const ServerSettingsPage({super.key});

  @override
  State<ServerSettingsPage> createState() => _ServerSettingsPageState();
}

class _ServerSettingsPageState extends State<ServerSettingsPage> {
  final ServerManager _serverManager = ServerManager();
  
  bool _isServerEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic>? _serverStatus;
  
  @override
  void initState() {
    super.initState();
    _loadServerSettings();
  }
  
  
  /// 加载服务器设置
  Future<void> _loadServerSettings() async {
    try {
      final status = await _serverManager.getServerStatus();
      setState(() {
        _serverStatus = status;
        _isServerEnabled = status['isEnabled'] ?? false;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('${AppLocalizations.of(context)!.load_server_settings_failed}: $e');
    }
  }
  
  /// 切换服务器状态
  Future<void> _toggleServer() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      bool success;
      if (_isServerEnabled) {
        await _serverManager.stopServer();
        success = true;
      } else {
        success = await _serverManager.startServer();
      }
      
      if (success) {
        await _loadServerSettings();
        _showSuccess(_isServerEnabled ? AppLocalizations.of(context)!.server_started : AppLocalizations.of(context)!.server_stopped_msg);
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
  
  
  /// 复制服务器URL
  void _copyServerUrl() {
    if (_serverStatus != null) {
      final url = _serverStatus!['url'];
      Clipboard.setData(ClipboardData(text: url));
      _showSuccess(AppLocalizations.of(context)!.server_url_copied);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadServerSettings,
            tooltip: AppLocalizations.of(context)!.refresh_status,
          ),
        ],
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
    final isRunning = _serverStatus?['isRunning'] ?? false;
    final url = _serverStatus?['url'] ?? '';
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.server_status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  isRunning ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isRunning ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning ? AppLocalizations.of(context)!.server_running : AppLocalizations.of(context)!.server_stopped,
                  style: TextStyle(
                    color: isRunning ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _toggleServer,
                  child: Text(isRunning ? AppLocalizations.of(context)!.server_stop : AppLocalizations.of(context)!.server_start),
                ),
              ],
            ),
            if (isRunning) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${AppLocalizations.of(context)!.server_address}: $url',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: _copyServerUrl,
                    tooltip: AppLocalizations.of(context)!.copy_url,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
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
            _buildApiEndpoint('GET', '/', AppLocalizations.of(context)!.server_status),
            _buildApiEndpoint('GET', '/api/hosts', AppLocalizations.of(context)!.get_all_hosts_files),
            _buildApiEndpoint('GET', '/api/hosts/{fileName}', AppLocalizations.of(context)!.get_specific_hosts_file),
            _buildApiEndpoint('GET', '/api/hosts/{fileName}/history', AppLocalizations.of(context)!.get_hosts_file_history),
            _buildApiEndpoint('GET', '/api/hosts/{fileName}/history/{historyId}', AppLocalizations.of(context)!.get_specific_history_content),
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
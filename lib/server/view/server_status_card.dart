import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/widget/dialog/qr_code_dialog.dart';
import 'package:hosts/widget/dialog/select_hosts_dialog.dart';

/// 服务器状态卡片组件
class ServerStatusCard extends StatelessWidget {
  final Map<String, dynamic>? serverStatus;
  final List<Map<String, String>> networkInterfaces;
  final Function(List<SimpleHostFile>?) onStartServer;
  final VoidCallback onStopServer;

  const ServerStatusCard({
    super.key,
    required this.serverStatus,
    required this.networkInterfaces,
    required this.onStartServer,
    required this.onStopServer,
  });

  /// 复制URL到剪贴板
  void _copyUrl(BuildContext context, String url) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.server_url_copied),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// 显示二维码对话框
  void _showQrCodeDialog(BuildContext context, String url) {
    QrCodeDialog.show(context, url: url);
  }

  /// 处理服务器切换
  Future<void> _handleServerToggle(BuildContext context) async {
    final isRunning = serverStatus?['isRunning'] ?? false;

    if (isRunning) {
      // 如果服务器正在运行，直接停止
      onStopServer();
    } else {
      // 如果服务器未运行，显示选择hosts文件对话框
      final selectedHosts = await SelectHostsDialog.show(context);
      if (selectedHosts != null && selectedHosts.isNotEmpty) {
        onStartServer(selectedHosts);
      }
    }
  }

  /// 构建地址芯片
  Widget _buildAddressChip(
    BuildContext context, {
    required String label,
    required String url,
  }) {
    // 不省略任何IP信息，全部展示
    final displayLabel = label;

    // 根据IP地址类型确定颜色主题
    final isLocalhost = label.contains('127.0.0.1');
    final isPrivateNetwork = label.contains('192.168.') ||
        label.contains('10.') ||
        label.contains('172.');

    Color primaryColor;
    Color backgroundColor;
    Color borderColor;

    if (isLocalhost) {
      // localhost 使用灰色主题
      primaryColor = Theme.of(context).colorScheme.onSurfaceVariant;
      backgroundColor = Theme.of(context).colorScheme.surfaceContainerHighest;
      borderColor = Theme.of(context).colorScheme.outline;
    } else if (isPrivateNetwork) {
      // 私有网络使用主色调
      primaryColor = Theme.of(context).colorScheme.primary;
      backgroundColor = Theme.of(context).colorScheme.primaryContainer;
      borderColor = Theme.of(context).colorScheme.primary;
    } else {
      // 其他地址使用次要色调
      primaryColor = Theme.of(context).colorScheme.secondary;
      backgroundColor = Theme.of(context).colorScheme.secondaryContainer;
      borderColor = Theme.of(context).colorScheme.secondary;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 二维码按钮
            IconButton(
              icon: Icon(
                Icons.qr_code,
                size: 18,
                color: primaryColor,
              ),
              onPressed: () => _showQrCodeDialog(context, url),
              tooltip: '显示二维码',
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
            ),
            const SizedBox(width: 8),
            // IP地址文本
            Flexible(
              child: Text(
                displayLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // 复制按钮
            IconButton(
              icon: Icon(
                Icons.copy,
                size: 18,
                color: primaryColor,
              ),
              onPressed: () => _copyUrl(context, url),
              tooltip: AppLocalizations.of(context)!.copy_url,
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 28,
                minHeight: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRunning = serverStatus?['isRunning'] ?? false;
    final url = serverStatus?['url'] ?? '';
    final port = serverStatus?['port'] ?? 1204;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题行
            Text(
              AppLocalizations.of(context)!.server_status,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            // 服务器状态行
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRunning
                    ? Theme.of(context)
                        .colorScheme
                        .primaryContainer
                        .withValues(alpha: 0.3)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRunning
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.2)
                      : Theme.of(context)
                          .colorScheme
                          .outline
                          .withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // 状态指示器
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRunning
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline,
                      boxShadow: isRunning
                          ? [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.4),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: isRunning
                        ? Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  // 状态文字
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isRunning
                              ? AppLocalizations.of(context)!.server_running
                              : AppLocalizations.of(context)!.server_stopped,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: isRunning
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        if (isRunning && port != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '端口: $port',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.7),
                                    ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // 操作按钮
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: isRunning
                              ? Colors.red.withValues(alpha: 0.2)
                              : Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () => _handleServerToggle(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isRunning
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        shadowColor: isRunning
                            ? Colors.red.withValues(alpha: 0.3)
                            : Colors.green.withValues(alpha: 0.3),
                      ),
                      icon: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isRunning
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      label: Text(
                        isRunning
                            ? AppLocalizations.of(context)!.server_stop
                            : AppLocalizations.of(context)!.server_start,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // 服务器地址信息
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppLocalizations.of(context)!.server_address}:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // 显示所有网络接口的IP地址
                    ...networkInterfaces.map((interface) {
                      final address = interface['address']!;
                      final serverUrl = 'http://$address:$port';

                      return _buildAddressChip(
                        context,
                        label: serverUrl.replaceFirst('http://', ''),
                        url: serverUrl,
                      );
                    }),
                    // 如果服务器运行中且有不同的URL，也显示实际运行的URL
                    if (isRunning &&
                        url.isNotEmpty &&
                        !networkInterfaces.any((interface) =>
                            'http://${interface['address']}:$port' == url))
                      _buildAddressChip(
                        context,
                        label: url.replaceFirst('http://', ''),
                        url: url,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/widget/dialog/qr_code_dialog.dart';

/// 服务器状态卡片组件
class ServerStatusCard extends StatelessWidget {
  final Map<String, dynamic>? serverStatus;
  final List<Map<String, String>> networkInterfaces;
  final VoidCallback onToggleServer;

  const ServerStatusCard({
    super.key,
    required this.serverStatus,
    required this.networkInterfaces,
    required this.onToggleServer,
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
            Row(
              children: [
                Icon(
                  isRunning
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  color: isRunning
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Text(
                  isRunning
                      ? AppLocalizations.of(context)!.server_running
                      : AppLocalizations.of(context)!.server_stopped,
                  style: TextStyle(
                    color: isRunning
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: onToggleServer,
                  child: Text(isRunning
                      ? AppLocalizations.of(context)!.server_stop
                      : AppLocalizations.of(context)!.server_start),
                ),
              ],
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
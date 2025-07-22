import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/utils/device_api_cache.dart';
import 'package:hosts/widget/dialog/qr_code_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

/// API文档弹窗
class ApiDocumentationDialog extends StatefulWidget {
  final String deviceIp;
  final int port;

  const ApiDocumentationDialog({
    super.key,
    required this.deviceIp,
    this.port = 1204,
  });

  @override
  State<ApiDocumentationDialog> createState() => _ApiDocumentationDialogState();
}

class _ApiDocumentationDialogState extends State<ApiDocumentationDialog> {
  List<Map<String, dynamic>> hostsFiles = [];
  bool isLoading = true;
  bool hasError = false;
  String? errorMessage;
  bool isBasicEndpointsExpanded = false;
  Map<String, bool> hostFileExpansionState = {};
  Map<String, List<Map<String, dynamic>>> hostFileHistories = {};

  @override
  void initState() {
    super.initState();
    _loadHostsFiles();
  }

  Future<void> _loadHostsFiles() async {
    try {
      setState(() {
        isLoading = true;
        hasError = false;
        errorMessage = null;
      });

      final data = await DeviceApiCache.getCachedDeviceData(widget.deviceIp);

      // 为每个hosts文件获取历史记录
      final Map<String, List<Map<String, dynamic>>> histories = {};
      for (final hostFile in data) {
        final fileName = hostFile['fileName'] as String?;
        if (fileName != null) {
          try {
            final history = await DeviceApiCache.getCachedHostsFileHistory(
              widget.deviceIp,
              fileName,
            );
            histories[fileName] = history;
          } catch (e) {
            // 如果获取历史失败，设置为空列表
            histories[fileName] = [];
          }
        }
      }

      setState(() {
        hostsFiles = data;
        hostFileHistories = histories;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = 'http://${widget.deviceIp}:${widget.port}';
    final screenSize = MediaQuery.of(context).size;

    return AlertDialog(
      insetPadding: EdgeInsets.all(16),
      title: Row(
        children: [
          Icon(Icons.api, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(AppLocalizations.of(context)!.api_docs),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: isLoading ? null : _loadHostsFiles,
            tooltip: AppLocalizations.of(context)!.refresh,
          ),
        ],
      ),
      content: SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 服务器地址信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.computer,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.server_address,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                        Text(
                          baseUrl,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.open_in_browser),
                        onPressed: () => _openInBrowser(baseUrl),
                        tooltip: AppLocalizations.of(context)!.open_in_browser,
                      ),
                      IconButton(
                        icon: Icon(Icons.qr_code),
                        onPressed: () => _showQrCode(context, baseUrl),
                        tooltip:
                            AppLocalizations.of(context)!.show_qr_code_tooltip,
                      ),
                      IconButton(
                        icon: Icon(Icons.copy),
                        onPressed: () => _copyToClipboard(context, baseUrl),
                        tooltip: AppLocalizations.of(context)!.copy_url,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // API端点列表
            Text(
              '${AppLocalizations.of(context)!.api_endpoints}：',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Expanded(
              child: isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(AppLocalizations.of(context)!
                              .getting_device_info),
                        ],
                      ),
                    )
                  : hasError
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 48, color: Colors.red),
                              SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!
                                  .get_device_info_failed),
                              if (errorMessage != null) ...[
                                SizedBox(height: 8),
                                Text(
                                  errorMessage!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                              SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadHostsFiles,
                                icon: Icon(Icons.refresh),
                                label:
                                    Text(AppLocalizations.of(context)!.retry),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 基础API端点
                              _buildBasicEndpoints(context, baseUrl),

                              const SizedBox(height: 16),

                              // Hosts文件相关API
                              if (hostsFiles.isNotEmpty) ...[
                                Text(
                                  AppLocalizations.of(context)!
                                      .available_hosts_files_api,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 8),
                                _buildHostsFilesLayout(
                                    context, baseUrl, screenSize),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .device_no_hosts_files,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
      ],
    );
  }

  /// 构建hosts文件布局 - 根据屏幕大小决定使用List还是GridView
  Widget _buildHostsFilesLayout(
      BuildContext context, String baseUrl, Size screenSize) {
    // 判断屏幕宽度，决定使用什么布局
    final isWideScreen = screenSize.width > 1200;

    if (isWideScreen && hostsFiles.length >= 2) {
      // 宽屏且文件数量多时使用StaggeredGridView
      return StaggeredGrid.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 8,
        children: hostsFiles.map((hostFile) {
          return StaggeredGridTile.fit(
            crossAxisCellCount: 1,
            child: _buildHostFileEndpoints(
              context,
              baseUrl,
              hostFile['fileName'] ?? '',
              hostFile['remark'] ?? '',
            ),
          );
        }).toList(),
      );
    } else {
      // 窄屏或文件数量少时使用Column
      return Column(
        children: hostsFiles
            .map((hostFile) => _buildHostFileEndpoints(
                  context,
                  baseUrl,
                  hostFile['fileName'] ?? '',
                  hostFile['remark'] ?? '',
                ))
            .toList(),
      );
    }
  }

  /// 构建基础API端点
  Widget _buildBasicEndpoints(BuildContext context, String baseUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                isBasicEndpointsExpanded = !isBasicEndpointsExpanded;
              });
            },
            child: Row(
              children: [
                Icon(Icons.api,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.basic_api,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                AnimatedRotation(
                  turns: isBasicEndpointsExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: isBasicEndpointsExpanded ? null : 0,
            child: isBasicEndpointsExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildApiEndpoint(
                        context,
                        'GET',
                        '/',
                        AppLocalizations.of(context)!.server_status,
                        baseUrl,
                        isCompact: true,
                      ),
                      _buildApiEndpoint(
                        context,
                        'GET',
                        '/api/hosts',
                        AppLocalizations.of(context)!.get_all_hosts_files,
                        baseUrl,
                        isCompact: true,
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 构建hosts文件相关的API端点
  Widget _buildHostFileEndpoints(
    BuildContext context,
    String baseUrl,
    String fileName,
    String remark,
  ) {
    final displayName = remark.isNotEmpty ? '$remark ($fileName)' : fileName;
    final isExpanded = hostFileExpansionState[fileName] ?? true;
    final histories = hostFileHistories[fileName] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                hostFileExpansionState[fileName] = !isExpanded;
              });
            },
            child: Row(
              children: [
                Icon(Icons.description,
                    size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    displayName,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (histories.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${histories.length}${AppLocalizations.of(context)!.history_count_suffix}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.expand_more,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Column(
                    children: [
                      const SizedBox(height: 8),

                      // 获取hosts文件内容
                      _buildApiEndpoint(
                        context,
                        'GET',
                        '/api/hosts/$fileName',
                        '${AppLocalizations.of(context)!.get_content_prefix} $displayName ${AppLocalizations.of(context)!.get_content_suffix}',
                        baseUrl,
                        isCompact: true,
                      ),

                      // 只有当有历史记录时才显示具体的历史记录API端点
                      if (histories.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.history_content} (${histories.length}${AppLocalizations.of(context)!.history_count_suffix}):',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              ...histories.take(5).map((history) {
                                final historyId =
                                    history['fileName'] ?? history['id'] ?? '';
                                if (historyId.isNotEmpty) {
                                  return _buildApiEndpoint(
                                    context,
                                    'GET',
                                    '/api/hosts/$fileName/history/$historyId',
                                    '${AppLocalizations.of(context)!.get_history_content_prefix} $historyId ${AppLocalizations.of(context)!.get_history_content_suffix}',
                                    baseUrl,
                                    isCompact: true,
                                    isHistoryEndpoint: true,
                                  );
                                }
                                return const SizedBox.shrink();
                              }),
                              if (histories.length > 5)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${AppLocalizations.of(context)!.more_history_records}${histories.length - 5}${AppLocalizations.of(context)!.more_history_records_suffix}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontStyle: FontStyle.italic,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 构建API端点项
  Widget _buildApiEndpoint(
    BuildContext context,
    String method,
    String path,
    String description,
    String baseUrl, {
    bool isCompact = false,
    bool isHistoryEndpoint = false,
  }) {
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

    final fullUrl = baseUrl + path;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isCompact ? 2 : 4),
      padding: EdgeInsets.all(isCompact ? 8 : 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(6),
        color: isHistoryEndpoint
            ? Colors.blue[25]
            : (isCompact ? Colors.grey[50] : null),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: methodColor,
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  method,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  path,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon:
                        Icon(Icons.open_in_browser, size: isCompact ? 16 : 18),
                    onPressed: () => _openInBrowser(fullUrl),
                    tooltip: AppLocalizations.of(context)!.open_in_browser,
                    constraints: BoxConstraints(
                      minWidth: isCompact ? 28 : 32,
                      minHeight: isCompact ? 28 : 32,
                    ),
                    padding: EdgeInsets.all(isCompact ? 2 : 4),
                  ),
                  IconButton(
                    icon: Icon(Icons.qr_code, size: isCompact ? 16 : 18),
                    onPressed: () => _showQrCode(context, fullUrl),
                    tooltip: AppLocalizations.of(context)!.show_qr_code_tooltip,
                    constraints: BoxConstraints(
                      minWidth: isCompact ? 28 : 32,
                      minHeight: isCompact ? 28 : 32,
                    ),
                    padding: EdgeInsets.all(isCompact ? 2 : 4),
                  ),
                  IconButton(
                    icon: Icon(Icons.copy, size: isCompact ? 16 : 18),
                    onPressed: () => _copyToClipboard(context, fullUrl),
                    tooltip: AppLocalizations.of(context)!.copy_url_tooltip,
                    constraints: BoxConstraints(
                      minWidth: isCompact ? 28 : 32,
                      minHeight: isCompact ? 28 : 32,
                    ),
                    padding: EdgeInsets.all(isCompact ? 2 : 4),
                  ),
                ],
              ),
            ],
          ),
          if (!isCompact) ...[
            const SizedBox(height: 4),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
          const SizedBox(height: 4),
          Text(
            fullUrl,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  /// 在浏览器中打开URL
  Future<void> _openInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// 显示二维码
  void _showQrCode(BuildContext context, String url) {
    QrCodeDialog.show(
      context,
      url: url,
      title: AppLocalizations.of(context)!.scan_qr_code_to_access,
    );
  }

  /// 复制到剪贴板
  Future<void> _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.server_url_copied),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

/// 显示API文档对话框的便捷函数
Future<void> showApiDocumentationDialog(
  BuildContext context,
  String deviceIp, {
  int port = 1204,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return ApiDocumentationDialog(
        deviceIp: deviceIp,
        port: port,
      );
    },
  );
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:hosts/util/device_api_cache.dart';
import 'package:hosts/util/nearby_devices_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

Future<void> accessDeviceDialog(BuildContext context, NearbyDevice device) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AccessDeviceDialog(device: device);
    },
  );
}

class AccessDeviceDialog extends StatefulWidget {
  final NearbyDevice device;

  const AccessDeviceDialog({
    super.key,
    required this.device,
  });

  @override
  State<AccessDeviceDialog> createState() => _AccessDeviceDialogState();
}

class _AccessDeviceDialogState extends State<AccessDeviceDialog> {
  List<SimpleHostFile> availableHosts = [];
  List<SimpleHostFile> existingHostFiles = [];
  late List<bool> selectedItems;
  bool isAllSelected = false;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  Map<String, int> historyCount = {};

  @override
  void initState() {
    super.initState();
    selectedItems = [];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadExistingHostFiles();
    _loadDeviceHosts();
  }

  Future<void> _loadExistingHostFiles() async {
    try {
      final String defaultHostsText = AppLocalizations.of(context)!.default_hosts_text;
      final SettingsManager settingsManager = SettingsManager();
      final List<dynamic> hostConfigs =
          await settingsManager.getList(settingKeyHostConfigs);

      final List<SimpleHostFile> hosts = [];
      for (final config in hostConfigs) {
        final hostFile = SimpleHostFile.fromJson(config);
        if (hostFile.fileName == "system") {
          hostFile.remark = defaultHostsText;
        }
        hosts.add(hostFile);
      }

      setState(() {
        existingHostFiles = hosts;
      });
    } catch (e) {
      // Ignore errors, use empty list
      setState(() {
        existingHostFiles = [];
      });
    }
  }

  Future<void> _loadDeviceHosts() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });

    try {
      final String defaultHostsText = AppLocalizations.of(context)!.default_hosts_text;
      
      // Refresh local file list
      await _loadExistingHostFiles();

      // Get device data directly, no caching
      final hostConfigs = await DeviceApiCache.getCachedDeviceData(widget.device.ip);

      final List<SimpleHostFile> hosts = [];
      final Map<String, int> historyCounts = {};
      
      for (final config in hostConfigs) {
        final hostFile = SimpleHostFile.fromJson(config);
        if (hostFile.fileName == "system") {
          hostFile.remark = defaultHostsText;
        }
        hosts.add(hostFile);
        
        // 获取每个hosts文件的历史记录数量
        try {
          final historyList = await DeviceApiCache.getCachedHostsFileHistory(
            widget.device.ip,
            hostFile.fileName,
          );
          historyCounts[hostFile.fileName] = historyList.length;
        } catch (e) {
          historyCounts[hostFile.fileName] = 0;
        }
      }

      setState(() {
        availableHosts = hosts;
        selectedItems = List.generate(hosts.length, (index) => false);
        historyCount = historyCounts;
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

  void _toggleSelectAll() {
    setState(() {
      isAllSelected = !isAllSelected;
      for (int i = 0; i < selectedItems.length; i++) {
        selectedItems[i] = isAllSelected;
      }
    });
  }

  void _toggleItem(int index) {
    setState(() {
      selectedItems[index] = !selectedItems[index];
      isAllSelected = selectedItems.every((item) => item);
    });
  }

  Future<void> _accessSelected() async {
    final List<SimpleHostFile> selectedHosts = [];
    for (int i = 0; i < availableHosts.length; i++) {
      if (selectedItems[i]) {
        selectedHosts.add(availableHosts[i]);
      }
    }

    if (selectedHosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error_null_data)),
      );
      return;
    }

    // 获取本地化字符串，在关闭对话框之前
    final String importSuccessMessage =
        AppLocalizations.of(context)!.import_success;
    final String remoteFilesText =
        AppLocalizations.of(context)!.remote_files;
    final String noImportableContentText =
        AppLocalizations.of(context)!.no_importable_content;
    final String importFailMessage =
        AppLocalizations.of(context)!.error_save_fail;
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);

    Navigator.of(context).pop();

    try {
      final FileManager fileManager = FileManager();
      final SettingsManager settingsManager = SettingsManager();
      final List<SimpleHostFile> importedFiles = [];

      for (final hostFile in selectedHosts) {
        // 获取远程文件内容
        final String? remoteContent =
            await DeviceApiCache.getCachedHostsFileContent(
          widget.device.ip,
          hostFile.fileName,
        );

        if (remoteContent != null && remoteContent.isNotEmpty) {
          // 直接使用原始文件名
          final String fileName = hostFile.fileName;

          // 创建本地文件
          await fileManager.createHosts(fileName);

          // 写入远程内容到本地文件
          final String localFilePath =
              await fileManager.getHostsFilePath(fileName);
          await File(localFilePath).writeAsString(remoteContent);

          // 导入hosts历史记录
          try {

            // 保存历史文件到本地，使用File直接写入
            final Directory historyDirPath = Directory(p.join(
                (await getApplicationSupportDirectory()).path,
                fileName,
                'history'
            ));

            if (!historyDirPath.existsSync()) {
              historyDirPath.createSync();
            }

            final List<Map<String, dynamic>> historyList =
                await DeviceApiCache.getCachedHostsFileHistory(
              widget.device.ip,
              fileName,
            );

            for (final historyItem in historyList) {
              final String historyFileName = historyItem['id'] ?? '';
              if (historyFileName.isNotEmpty) {
                // 获取历史文件内容
                final String? historyContent =
                    await DeviceApiCache.getCachedHostsFileHistoryContent(
                  widget.device.ip,
                  fileName,
                  historyFileName,
                );

                if (historyContent != null && historyContent.isNotEmpty) {
                  // 直接写入历史文件，文件名保持与远程一致
                  final String historyFilePath = p.join(historyDirPath.path, historyFileName);
                  await File(historyFilePath).writeAsString(historyContent);
                }
              }
            }
          } catch (e) {
            print('导入hosts历史失败 $fileName: $e');
            // 历史导入失败不影响主文件导入，继续处理
          }

          // 创建本地SimpleHostFile对象
          final SimpleHostFile localHostFile = SimpleHostFile(
            fileName: fileName,
            remark: hostFile.remark,
          );

          importedFiles.add(localHostFile);
        }
      }

      if (importedFiles.isNotEmpty) {
        // 获取当前配置
        List<dynamic> hostConfigs =
            await settingsManager.getList(settingKeyHostConfigs);

        // 添加导入的文件到配置中
        for (final importedFile in importedFiles) {
          // 检查是否已存在相同fileName的配置
          int existingIndex = hostConfigs.indexWhere(
              (config) => config['fileName'] == importedFile.fileName);

          if (existingIndex >= 0) {
            // 如果存在，则覆盖
            hostConfigs[existingIndex] = importedFile.toJson();
          } else {
            // 如果不存在，则添加
            hostConfigs.add(importedFile.toJson());
          }
        }

        // 保存到settingsManager
        await settingsManager.setList(settingKeyHostConfigs, hostConfigs);

        scaffoldMessenger.showSnackBar(
          SnackBar(
              content:
                  Text('$importSuccessMessage ${importedFiles.length}$remoteFilesText')),
        );
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(noImportableContentText)),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('$importFailMessage: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = selectedItems.where((item) => item).length;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.computer, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.import_remote_hosts),
                Text(
                  widget.device.ip,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 设备信息
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.share,
                    color: Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.sharing_enabled,
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: isLoading ? null : _loadDeviceHosts,
                    tooltip: AppLocalizations.of(context)!.refresh,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (isLoading)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.getting_remote_hosts),
                    ],
                  ),
                ),
              )
            else if (hasError)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.connection_failed),
                      if (errorMessage != null) ...[
                        SizedBox(height: 8),
                        Text(
                          errorMessage!,
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadDeviceHosts,
                        icon: Icon(Icons.refresh),
                        label: Text(AppLocalizations.of(context)!.retry),
                      ),
                    ],
                  ),
                ),
              )
            else if (availableHosts.isNotEmpty) ...[
              // 全选/反选按钮和统计
              Row(
                children: [
                  Checkbox(
                    value: isAllSelected,
                    onChanged: (bool? value) => _toggleSelectAll(),
                  ),
                  Text(AppLocalizations.of(context)!.select_all),
                  const Spacer(),
                  Text('$selectedCount/${availableHosts.length}'),
                ],
              ),
              const Divider(),
              // hosts文件列表
              Expanded(
                child: ListView.builder(
                  itemCount: availableHosts.length,
                  itemBuilder: (context, index) {
                    final host = availableHosts[index];
                    final bool isExisting = existingHostFiles.any(
                        (existingFile) =>
                            existingFile.fileName == host.fileName);

                    return ListTile(
                      leading: Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      trailing: Checkbox(
                        value: selectedItems[index],
                        onChanged: (bool? value) => _toggleItem(index),
                      ),
                      title: Text(host.remark),
                      subtitle: (historyCount[host.fileName] != null && historyCount[host.fileName]! > 0) || isExisting
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (historyCount[host.fileName] != null && historyCount[host.fileName]! > 0)
                                  Text(
                                    '${AppLocalizations.of(context)!.history_count}: ${historyCount[host.fileName]}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                if (isExisting)
                                  Text(
                                    AppLocalizations.of(context)!.will_overwrite,
                                    style: TextStyle(
                                      color: Theme.of(context).colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            )
                          : null,
                      onTap: () => _toggleItem(index),
                    );
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.no_hosts_files_found),
                      Text(
                        AppLocalizations.of(context)!.device_no_shared_files,
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton(
          onPressed: (selectedCount > 0 && !isLoading) ? _accessSelected : null,
          child: Text(AppLocalizations.of(context)!.import),
        ),
      ],
    );
  }
}

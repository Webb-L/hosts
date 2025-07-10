import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';

Future<void> importHostsDialog(
    BuildContext context, List<SimpleHostFile> existingHostFiles, {VoidCallback? onImportSuccess}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return ImportHostsDialog(existingHostFiles: existingHostFiles, onImportSuccess: onImportSuccess);
    },
  );
}

class ImportHostsDialog extends StatefulWidget {
  final List<SimpleHostFile> existingHostFiles;
  final VoidCallback? onImportSuccess;

  const ImportHostsDialog({super.key, required this.existingHostFiles, this.onImportSuccess});

  @override
  State<ImportHostsDialog> createState() => _ImportHostsDialogState();
}

class _ImportHostsDialogState extends State<ImportHostsDialog> {
  List<ImportableHost> importableHosts = [];
  late List<bool> selectedItems;
  bool isAllSelected = false;
  bool isLoading = false;
  String? selectedFilePath;

  @override
  void initState() {
    super.initState();
    selectedItems = [];
  }

  Future<void> _selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          isLoading = true;
          selectedFilePath = result.files.single.path;
          importableHosts = [];
          selectedItems = [];
        });

        final FileManager fileManager = FileManager();
        final List<ImportableHost> hosts = 
            await fileManager.parseImportFile(selectedFilePath!);

        setState(() {
          importableHosts = hosts;
          selectedItems = List.generate(hosts.length, (index) => false);
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.error_open_file}: $e')),
        );
      }
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

  Future<void> _importSelected() async {
    if (selectedFilePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error_null_data)),
      );
      return;
    }

    final List<ImportableHost> selectedHosts = [];
    for (int i = 0; i < importableHosts.length; i++) {
      if (selectedItems[i]) {
        selectedHosts.add(importableHosts[i]);
      }
    }

    if (selectedHosts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.error_null_data)),
      );
      return;
    }

    // 获取本地化字符串和ScaffoldMessenger，在关闭对话框之前
    final String importSuccessMessage = AppLocalizations.of(context)!.import_success;
    final String importFailMessage = AppLocalizations.of(context)!.error_save_fail;
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    
    Navigator.of(context).pop();

    try {
      
      final FileManager fileManager = FileManager();
      final SettingsManager settingsManager = SettingsManager();
      final List<String> existingFileNames = 
          widget.existingHostFiles.map((e) => e.fileName).toList();
      
      // 导入文件
      final List<SimpleHostFile> importedFiles = await fileManager.importSelectedHosts(
        selectedFilePath!,
        selectedHosts,
        existingFileNames,
      );

      if (importedFiles.isNotEmpty) {
        // 获取当前配置
        List<dynamic> hostConfigs = await settingsManager.getList(settingKeyHostConfigs);
        
        // 添加或更新导入的文件到配置中
        for (final importedFile in importedFiles) {
          // 查找是否已存在相同fileName的配置
          int existingIndex = hostConfigs.indexWhere((config) => 
            config['fileName'] == importedFile.fileName);
          
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
          SnackBar(content: Text('$importSuccessMessage ${importedFiles.length}')),
        );
        
        // 调用成功回调来刷新数据
        widget.onImportSuccess?.call();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(importFailMessage)),
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
      title: Text(AppLocalizations.of(context)!.import_data),
      content: SizedBox(
        width: 500,
        height: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 文件选择按钮
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: isLoading ? null : _selectFile,
                  icon: Icon(Icons.file_open),
                  label: Text(AppLocalizations.of(context)!.open_file),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    selectedFilePath != null 
                        ? selectedFilePath!.split('/').last 
                        : AppLocalizations.of(context)!.error_null_data,
                    style: Theme.of(context).textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
                      Text('${AppLocalizations.of(context)!.file_processing}...'),
                    ],
                  ),
                ),
              )
            else if (importableHosts.isNotEmpty) ...[
              // 全选/反选按钮和统计
              Row(
                children: [
                  Checkbox(
                    value: isAllSelected,
                    onChanged: (bool? value) => _toggleSelectAll(),
                  ),
                  Text(AppLocalizations.of(context)!.select_all),
                  const Spacer(),
                  Text('$selectedCount/${importableHosts.length}'),
                ],
              ),
              const Divider(),
              // hosts文件列表
              Expanded(
                child: ListView.builder(
                  itemCount: importableHosts.length,
                  itemBuilder: (context, index) {
                    final host = importableHosts[index];
                    final bool isExisting = widget.existingHostFiles.any((existingFile) => 
                        existingFile.fileName == host.fileName);
                    
                    return ListTile(
                      trailing: Checkbox(
                        value: selectedItems[index],
                        onChanged: (bool? value) => _toggleItem(index),
                      ),
                      title: Text(host.remark),
                      subtitle: isExisting 
                          ? Text(
                              AppLocalizations.of(context)!.will_overwrite,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      onTap: () => _toggleItem(index),
                    );
                  },
                ),
              ),
            ] else if (selectedFilePath != null) ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, size: 48, color: Colors.orange),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.error_null_data),
                      Text(AppLocalizations.of(context)!.error_open_file, 
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.import_file),
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
          onPressed: (selectedCount > 0 && !isLoading) ? _importSelected : null,
          child: Text(AppLocalizations.of(context)!.import),
        ),
      ],
    );
  }
}
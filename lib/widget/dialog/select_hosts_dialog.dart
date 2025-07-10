import 'package:flutter/material.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/settings_manager.dart';

/// 选择要共享的hosts文件对话框
class SelectHostsDialog extends StatefulWidget {
  const SelectHostsDialog({super.key});

  /// 显示选择hosts文件对话框
  static Future<List<SimpleHostFile>?> show(BuildContext context) {
    return showDialog<List<SimpleHostFile>>(
      context: context,
      builder: (BuildContext context) {
        return const SelectHostsDialog();
      },
    );
  }

  @override
  State<SelectHostsDialog> createState() => _SelectHostsDialogState();
}

class _SelectHostsDialogState extends State<SelectHostsDialog> {
  final SettingsManager _settingsManager = SettingsManager();
  List<SimpleHostFile> _hostFiles = [];
  Set<String> _selectedFileNames = {};
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadHostFiles();
  }

  /// 加载所有hosts文件
  Future<void> _loadHostFiles() async {
    try {
      final List<dynamic> hostConfigs = await _settingsManager.getList(settingKeyHostConfigs);
      final List<SimpleHostFile> hostFiles = [];

      for (Map<String, dynamic> config in hostConfigs) {
        SimpleHostFile hostFile = SimpleHostFile.fromJson(config);
        hostFiles.add(hostFile);
      }

      setState(() {
        _hostFiles = hostFiles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  /// 切换文件选择状态
  void _toggleFileSelection(String fileName, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedFileNames.add(fileName);
      } else {
        _selectedFileNames.remove(fileName);
      }
    });
  }

  /// 切换全选状态
  void _toggleSelectAll(bool selectAll) {
    setState(() {
      if (selectAll) {
        _selectedFileNames = _hostFiles.map((f) => f.fileName).toSet();
      } else {
        _selectedFileNames.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.select_hosts_to_export),
      content: SizedBox(
        width: 500,
        height: 400,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        TextButton(
          onPressed: _selectedFileNames.isEmpty
              ? null
              : () {
                  final selectedFiles = _hostFiles
                      .where((f) => _selectedFileNames.contains(f.fileName))
                      .toList();
                  Navigator.of(context).pop(selectedFiles);
                },
          child: Text('${AppLocalizations.of(context)!.ok} (${_selectedFileNames.length})'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                  _isLoading = true;
                });
                _loadHostFiles();
              },
              child: Text(AppLocalizations.of(context)!.refresh_status),
            ),
          ],
        ),
      );
    }

    if (_hostFiles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.error_null_data,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // 全选/取消全选
        ListTile(
          title: Text(
            AppLocalizations.of(context)!.select_all,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text('${_hostFiles.length} 个文件'),
          leading: Checkbox(
            value: _selectedFileNames.length == _hostFiles.length && _hostFiles.isNotEmpty,
            tristate: true,
            onChanged: (value) {
              if (value == null) return;
              _toggleSelectAll(value);
            },
          ),
          onTap: () {
            final allSelected = _selectedFileNames.length == _hostFiles.length && _hostFiles.isNotEmpty;
            _toggleSelectAll(!allSelected);
          },
          contentPadding: EdgeInsets.zero,
        ),
        const Divider(),
        // 文件列表
        Expanded(
          child: ListView.builder(
            itemCount: _hostFiles.length,
            itemBuilder: (context, index) {
              final hostFile = _hostFiles[index];
              final isSelected = _selectedFileNames.contains(hostFile.fileName);

              return ListTile(
                title: Text(
                  hostFile.remark.isNotEmpty ? hostFile.remark : hostFile.fileName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                leading: Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    _toggleFileSelection(hostFile.fileName, value ?? false);
                  },
                ),
                onTap: () {
                  _toggleFileSelection(hostFile.fileName, !isSelected);
                },
                contentPadding: EdgeInsets.zero,
              );
            },
          ),
        ),
      ],
    );
  }
}
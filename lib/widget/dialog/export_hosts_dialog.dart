import 'package:flutter/material.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';

Future<void> exportHostsDialog(
    BuildContext context, List<SimpleHostFile> hostFiles) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return ExportHostsDialog(hostFiles: hostFiles);
    },
  );
}

class ExportHostsDialog extends StatefulWidget {
  final List<SimpleHostFile> hostFiles;

  const ExportHostsDialog({super.key, required this.hostFiles});

  @override
  State<ExportHostsDialog> createState() => _ExportHostsDialogState();
}

class _ExportHostsDialogState extends State<ExportHostsDialog> {
  late List<bool> selectedItems;
  bool isAllSelected = false;

  @override
  void initState() {
    super.initState();
    selectedItems = List.generate(widget.hostFiles.length, (index) => false);
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

  Future<void> _exportSelected() async {
    final List<SimpleHostFile> selectedHostFiles = [];
    for (int i = 0; i < widget.hostFiles.length; i++) {
      if (selectedItems[i]) {
        selectedHostFiles.add(widget.hostFiles[i]);
      }
    }

    if (selectedHostFiles.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.select_hosts_to_export)),
        );
      }
      return;
    }

    // 获取本地化字符串，在关闭对话框之前
    final String exportDataTitle = AppLocalizations.of(context)!.export_data;
    final String exportSuccessMessage = AppLocalizations.of(context)!.export_success;
    
    // 获取ScaffoldMessenger，在关闭对话框之前
    final ScaffoldMessengerState scaffoldMessenger = ScaffoldMessenger.of(context);
    
    Navigator.of(context).pop();

    final FileManager fileManager = FileManager();
    bool success = false;

    try {
      // 统一使用批量导出方法
      success = await fileManager.exportMultipleHostFiles(
        selectedHostFiles,
        exportDataTitle,
      );

      if (success) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text(exportSuccessMessage)),
        );
      }
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('${AppLocalizations.of(context)!.export_failed}: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = selectedItems.where((item) => item).length;

    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.export_data),
      content: SizedBox(
        width: 500,
        height: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 全选/反选按钮和统计
            Row(
              children: [
                Checkbox(
                  value: isAllSelected,
                  onChanged: (bool? value) => _toggleSelectAll(),
                ),
                Text(AppLocalizations.of(context)!.select_all),
                const Spacer(),
                Text('${AppLocalizations.of(context)!.selected_count}: $selectedCount/${widget.hostFiles.length}'),
              ],
            ),
            const Divider(),
            // hosts文件列表
            Expanded(
              child: ListView.builder(
                itemCount: widget.hostFiles.length,
                itemBuilder: (context, index) {
                  final hostFile = widget.hostFiles[index];
                  return ListTile(
                    trailing: Checkbox(
                      value: selectedItems[index],
                      onChanged: (bool? value) => _toggleItem(index),
                    ),
                    title: Text(hostFile.remark),
                    onTap: () => _toggleItem(index),
                  );
                },
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
        FilledButton(
          onPressed: selectedCount > 0 ? _exportSelected : null,
          child: Text(AppLocalizations.of(context)!.export),
        ),
      ],
    );
  }
}
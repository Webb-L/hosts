import 'package:flutter/material.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:hosts/util/string_util.dart';
import 'package:hosts/widget/dialog/dialog.dart';

class CreateHostFileDialog extends StatelessWidget {
  final void Function(String) onSyncChanged;

  CreateHostFileDialog({super.key, required this.onSyncChanged});

  final SettingsManager _settingsManager = SettingsManager();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          String? remark = await hostConfigDialog(context);
          if (remark == null || remark.isEmpty) return;
          List<dynamic> hostConfigs =
              await _settingsManager.getList(settingKeyHostConfigs);
          final String fileName = generateRandomString(18);

          hostConfigs.add(SimpleHostFile(fileName: fileName, remark: remark));

          await FileManager().createHosts(fileName);
          await _settingsManager.setList(settingKeyHostConfigs, hostConfigs);
          onSyncChanged(fileName);
        },
        icon: const Icon(Icons.add));
  }
}

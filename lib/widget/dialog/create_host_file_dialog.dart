import 'package:flutter/material.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:hosts/util/string_util.dart';

class CreateHostFileDialog extends StatelessWidget {
  CreateHostFileDialog({super.key});

  final SettingsManager _settingsManager = SettingsManager();

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () async {
          String? remark = await showInputDialog(context);
          if (remark == null || remark.isEmpty) return;
          List<dynamic> hostConfigs =
              await _settingsManager.getList(settingKeyHostConfigs);
          final String fileName = generateRandomString(18);

          hostConfigs.add(SimpleHostFile(fileName: fileName, remark: remark));

          await FileManager().createHosts(fileName);
          await _settingsManager.setList(settingKeyHostConfigs, hostConfigs);
        },
        icon: const Icon(Icons.add));
  }

  Future<String?> showInputDialog(BuildContext context) {
    final TextEditingController remarkController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('创建'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: remarkController,
              maxLength: 30,
              validator: (value) {
                final text = value ?? "";
                if (text.isEmpty) return "请输入备注";
                return null;
              },
              decoration: const InputDecoration(
                labelText: '备注',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(context).pop(remarkController.text);
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }
}

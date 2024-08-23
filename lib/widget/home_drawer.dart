import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:hosts/widget/dialog/create_host_file_dialog.dart';

class HomeDrawer extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const HomeDrawer({super.key, required this.onChanged});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final SettingsManager _settingsManager = SettingsManager();
  final FileManager _fileManager = FileManager();

  SimpleHostFile? useHostFile;
  SimpleHostFile? selectHostFile;
  final List<SimpleHostFile> hostFiles = [];

  @override
  void initState() {
    (() async {
      List<SimpleHostFile> tempHostFiles = [];
      List<dynamic> hostConfigs =
          await _settingsManager.getList(settingKeyHostConfigs);
      String? useHostFileKey =
          await _settingsManager.getString(settingKeyUseHostFile);
      for (Map<String, dynamic> config in hostConfigs) {
        SimpleHostFile hostFile = SimpleHostFile.fromJson(config);
        if (hostFile.fileName == useHostFileKey) {
          useHostFile = hostFile;
          selectHostFile = hostFile;
        }
        tempHostFiles.add(hostFile);
      }

      setState(() {
        hostFiles.clear();
        hostFiles.addAll(tempHostFiles);
      });
    })();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  "Hosts Editor",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Expanded(child: SizedBox()),
                CreateHostFileDialog(),
                IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.file_open_outlined))
              ],
            ),
          ),
          Expanded(
            // 使用 Expanded 包裹 ListView
            child: ListView.builder(
                itemCount: hostFiles.length,
                itemBuilder: (context, index) {
                  SimpleHostFile hostFile = hostFiles[index];
                  return ListTile(
                    title: Text(hostFile.remark),
                    leading: IconButton(
                      tooltip: "使用",
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        await Process.start("pkexec", ["env"]);
                        setState(() {
                          useHostFile = hostFile;
                        });
                        _settingsManager.setString(
                            settingKeyUseHostFile, hostFile.fileName);
                      },
                      icon: Icon(useHostFile == hostFile
                          ? Icons.star
                          : Icons.star_border),
                    ),
                    trailing: buildMoreButton(hostFile),
                    selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                    selected: selectHostFile == hostFile,
                    onTap: () async {
                      if (selectHostFile == hostFile) return;
                      setState(() {
                        selectHostFile = hostFile;
                      });
                      widget.onChanged(await _fileManager
                          .getHostsFilePath(hostFile.fileName));
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget buildMoreButton(SimpleHostFile hostFile) {
    return PopupMenuButton<int>(
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
      ),
      onSelected: (value) {
        switch (value) {
          case 1:
            break;
          case 2:
            break;
          case 3:
            deleteMultiple([hostFile]);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          {'icon': Icons.edit, 'text': '编辑', 'value': 1},
          {'icon': Icons.history, 'text': '历史', 'value': 2},
          {'icon': Icons.delete_outline, 'text': '删除', 'value': 3},
        ].map((item) {
          return PopupMenuItem<int>(
            value: int.parse(item['value'].toString()),
            child: Row(
              children: [
                Icon(item['icon']! as IconData),
                const SizedBox(width: 8),
                Text(item['text']!.toString()),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  void deleteMultiple(List<SimpleHostFile> array) {
    if (array.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(array.length == 1
          ? "您确认需要删除《${array.first.remark}》吗？"
          : "确认删除选中的${array.length}条记录吗？"),
      action: SnackBarAction(label: "确认", onPressed: () {}),
    ));
  }
}

import "dart:io";

import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import "package:hosts/model/simple_host_file.dart";
import "package:hosts/util/file_manager.dart";
import "package:hosts/util/settings_manager.dart";
import "package:hosts/widget/dialog/create_host_file_dialog.dart";
import "package:hosts/widget/dialog/dialog.dart";
import "package:hosts/widget/snakbar.dart";

class HomeDrawer extends StatefulWidget {
  final bool isSave;
  final void Function(String, String) onChanged;

  const HomeDrawer({super.key, required this.isSave, required this.onChanged});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  final SettingsManager _settingsManager = SettingsManager();
  final FileManager _fileManager = FileManager();

  String? useHostFile;
  String? selectHostFile;
  final List<SimpleHostFile> hostFiles = [];

  @override
  void initState() {
    (() async {
      loadHostFiles(await _settingsManager.getBool(settingKeyFirstOpenApp));
    })();
    super.initState();
  }

  Future<void> loadHostFiles([bool isInit = false]) async {
    List<SimpleHostFile> tempHostFiles = [];
    List<dynamic> hostConfigs =
        await _settingsManager.getList(settingKeyHostConfigs);
    useHostFile = await _settingsManager.getString(settingKeyUseHostFile);

    if (isInit) {
      selectHostFile = useHostFile;
    }

    for (Map<String, dynamic> config in hostConfigs) {
      SimpleHostFile hostFile = SimpleHostFile.fromJson(config);
      tempHostFiles.add(hostFile);

      if (hostFile.fileName == "system") {
        hostFile.remark = AppLocalizations.of(context)!.default_hosts_text;
        if (isInit) {
          widget.onChanged(
              await _fileManager.getHostsFilePath(hostFile.fileName),
              hostFile.fileName);
        }
        continue;
      }

      if (hostFile.fileName ==
          await _settingsManager.getString(settingKeyUseHostFile)) {
        widget.onChanged(await _fileManager.getHostsFilePath(hostFile.fileName),
            hostFile.fileName);
      }
    }

    setState(() {
      hostFiles.clear();
      hostFiles.addAll(tempHostFiles);
    });
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
                  AppLocalizations.of(context)!.app_name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Expanded(child: SizedBox()),
                CreateHostFileDialog(onSyncChanged: () {
                  loadHostFiles();
                }),
                // IconButton(
                //     onPressed: () async {},
                //     icon: const Icon(Icons.file_open_outlined))
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: hostFiles.length,
                itemBuilder: (context, index) {
                  SimpleHostFile hostFile = hostFiles[index];
                  return ListTile(
                    title: Text(hostFile.remark),
                    leading: IconButton(
                      tooltip: AppLocalizations.of(context)!.use,
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: useHostFile == hostFile.fileName
                          ? null
                          : () async {
                              final String path = await _fileManager
                                  .getHostsFilePath(hostFile.fileName);

                              try {
                                await _fileManager
                                    .saveToHosts(File(path).readAsStringSync());
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            AppLocalizations.of(context)!
                                                .error_use_fail)));
                                return;
                              }

                              setState(() {
                                useHostFile = hostFile.fileName;
                              });
                              _settingsManager.setString(
                                  settingKeyUseHostFile, hostFile.fileName);
                            },
                      icon: Icon(useHostFile == hostFile.fileName
                          ? Icons.star
                          : Icons.star_border),
                    ),
                    trailing: buildMoreButton(hostFile),
                    selectedTileColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    selected: selectHostFile == hostFile.fileName,
                    onTap: () async {
                      if (selectHostFile == hostFile.fileName) return;
                      if (!widget.isSave) {
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.error_not_save),
                          action: SnackBarAction(
                              label: AppLocalizations.of(context)!.abort,
                              onPressed: () async {
                                setState(() {
                                  selectHostFile = hostFile.fileName;
                                });
                                widget.onChanged(
                                    await _fileManager
                                        .getHostsFilePath(hostFile.fileName),
                                    hostFile.fileName);
                              }),
                        ));
                        return;
                      }
                      setState(() {
                        selectHostFile = hostFile.fileName;
                      });
                      widget.onChanged(
                          await _fileManager
                              .getHostsFilePath(hostFile.fileName),
                          hostFile.fileName);
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  Widget buildMoreButton(SimpleHostFile hostFile) {
    if (hostFile.fileName == "system") {
      return const SizedBox();
    }

    return PopupMenuButton<int>(
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
      ),
      onSelected: (value) async {
        switch (value) {
          case 1:
            String result =
                (await hostConfigDialog(context, hostFile.remark) ?? "");
            if (result.isEmpty) return;
            int index = hostFiles.indexOf(hostFile);
            if (index == -1) return;
            hostFile.remark = result;
            hostFiles[index] = hostFile;
            await _settingsManager.setList(settingKeyHostConfigs, hostFiles);
            loadHostFiles();
            break;
          case 2:
            final List<SimpleHostFile> list = [hostFile];
            deleteMultiple(context, list.map((item) => item.remark).toList(),
                () async {
              setState(() {
                hostFiles.removeWhere((hostFile) => list.contains(hostFile));
              });
              await _settingsManager.setList(settingKeyHostConfigs, hostFiles);
              selectHostFile =
                  await _settingsManager.getString(settingKeyUseHostFile);
              widget.onChanged(
                  await _fileManager.getHostsFilePath(selectHostFile!),
                  selectHostFile!);
              _fileManager
                  .deleteFiles(list.map((file) => file.fileName).toList());
            });
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        List<Map<String, Object>> list = [
          {
            "icon": Icons.edit,
            "text": AppLocalizations.of(context)!.edit,
            "value": 1
          },
          {
            "icon": Icons.delete_outline,
            "text": AppLocalizations.of(context)!.remove,
            "value": 2
          },
        ];

        return list.map((item) {
          return PopupMenuItem<int>(
            value: int.parse(item["value"].toString()),
            child: Row(
              children: [
                Icon(item["icon"]! as IconData),
                const SizedBox(width: 8),
                Text(item["text"]!.toString()),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}

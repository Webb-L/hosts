import "package:flutter/material.dart";
import "package:hosts/model/simple_host_file.dart";
import "package:hosts/util/file_manager.dart";
import "package:hosts/util/settings_manager.dart";
import "package:hosts/widget/dialog/create_host_file_dialog.dart";

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
    loadHostFiles(true);
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
      if (hostFile.fileName == "system" && isInit) {
        widget.onChanged(await _fileManager.getHostsFilePath(hostFile.fileName),
            hostFile.fileName);
      }
      tempHostFiles.add(hostFile);
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
                  "Hosts Editor",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Expanded(child: SizedBox()),
                CreateHostFileDialog(onSyncChanged: () {
                  loadHostFiles();
                }),
                IconButton(
                    onPressed: () async {},
                    icon: const Icon(Icons.file_open_outlined))
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
                      tooltip: "使用",
                      style: OutlinedButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () async {
                        // await Process.start(
                        //     "runas /user:Administrator", ["env"]);
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
                          content: const Text("当前文件包含未保存的更改"),
                          action: SnackBarAction(
                              label: "舍弃",
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
            String result = (await showInputDialog(hostFile) ?? "");
            if (result.isEmpty) return;
            int index = hostFiles.indexOf(hostFile);
            if (index == -1) return;
            hostFile.remark = result;
            hostFiles[index] = hostFile;
            await _settingsManager.setList(settingKeyHostConfigs, hostFiles);
            loadHostFiles();
            break;
          case 2:
            deleteMultiple([hostFile]);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        List<Map<String, Object>> list = [
          {"icon": Icons.edit, "text": "编辑", "value": 1},
          {"icon": Icons.delete_outline, "text": "删除", "value": 2},
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

  Future<String?> showInputDialog(SimpleHostFile simpleHostFile) {
    final TextEditingController remarkController =
        TextEditingController(text: simpleHostFile.remark);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return showDialog<String?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("编辑"),
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
                labelText: "备注",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("取消"),
            ),
            TextButton(
              onPressed: () async {
                if (!(formKey.currentState?.validate() ?? false)) return;
                Navigator.of(context).pop(remarkController.text);
              },
              child: const Text("确定"),
            ),
          ],
        );
      },
    );
  }

  void deleteMultiple(List<SimpleHostFile> array) {
    if (array.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(array.length == 1
          ? "您确认需要删除《${array.first.remark}》吗？"
          : "确认删除选中的${array.length}条记录吗？"),
      action: SnackBarAction(
          label: "确认",
          onPressed: () async {
            setState(() {
              hostFiles.removeWhere((hostFile) => array.contains(hostFile));
            });
            await _settingsManager.setList(settingKeyHostConfigs, hostFiles);
            selectHostFile =
                await _settingsManager.getString(settingKeyUseHostFile);
            widget.onChanged(
                await _fileManager.getHostsFilePath(selectHostFile!),
                selectHostFile!);
            _fileManager
                .deleteFiles(array.map((file) => file.fileName).toList());
          }),
    ));
  }
}

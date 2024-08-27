import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:hosts/widget/app_bar/home_app_bar.dart';
import 'package:hosts/widget/dialog/copy_dialog.dart';
import 'package:hosts/widget/error/error_empty.dart';
import 'package:hosts/widget/home_drawer.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SettingsManager _settingsManager = SettingsManager();
  final FileManager _fileManager = FileManager();
  final List<HostsModel> selectHosts = [];
  HostsFile hostsFile = HostsFile("", "");
  EditMode editMode = EditMode.Table;
  AdvancedSettingsEnum advancedSettingsEnum = AdvancedSettingsEnum.Close;
  String searchText = "";
  Map<String, int?> sortConfig = {
    "host": null,
    "isUse": 1,
    "hosts": null,
    "description": null,
  };
  SimpleHostFileHistory? selectHistory;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    _textEditingController.addListener(() {
      String content =
          _textEditingController.text.replaceAll(" ", "").replaceAll("	", "");
      setState(() {
        hostsFile.isSave = hostsFile.defaultContent == content;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<HostsModel> filterHosts =
        hostsFile.filterHosts(searchText, sortConfig);
    return Scaffold(
      floatingActionButton: editMode == EditMode.Table
          ? FloatingActionButton(
              onPressed: () async {
                List<HostsModel>? hostsModels = await Navigator.of(context)
                    .push(MaterialPageRoute(
                        builder: (context) => const HostPage()));
                if (hostsModels == null) return;
                setState(() {
                  for (HostsModel hostsModel in hostsModels) {
                    hostsFile.addHost(hostsModel);
                  }
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Row(
        children: [
          if (advancedSettingsEnum == AdvancedSettingsEnum.Close)
            HomeDrawer(
              isSave: hostsFile.isSave,
              onChanged: (String value, String fileId) {
                setState(() {
                  selectHosts.clear();
                  hostsFile = HostsFile(value, fileId);
                  if (editMode == EditMode.Text) {
                    _textEditingController.value =
                        TextEditingValue(text: hostsFile.toString());
                  }
                });
              },
            ),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 12),
                HomeAppBar(
                  isSave: hostsFile.isSave,
                  undoHost: () {
                    setState(() {
                      hostsFile.undoHost();
                    });
                  },
                  searchText: searchText,
                  onSearchChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  advancedSettingsEnum: advancedSettingsEnum,
                  onSwitchAdvancedSettings: (AdvancedSettingsEnum value) {
                    setState(() {
                      advancedSettingsEnum = value;
                    });
                  },
                  editMode: editMode,
                  onSwitchMode: (value) {
                    setState(() {
                      if (editMode == EditMode.Text) {
                        editMode = EditMode.Table;
                        hostsFile.formString(_textEditingController.text);
                        selectHosts.clear();
                      } else {
                        editMode = EditMode.Text;
                        _textEditingController.value =
                            TextEditingValue(text: hostsFile.toString());
                      }
                    });
                  },
                  hosts: selectHosts,
                  sortConfig: sortConfig,
                  onDeletePressed: () {
                    deleteMultiple(selectHosts);
                  },
                  isCheckedAll: hostsFile.hosts.length == selectHosts.length,
                  onCheckedAllChanged: (value) {
                    setState(() {
                      selectHosts.clear();
                      if (value ?? false) {
                        selectHosts.addAll(hostsFile.hosts);
                      }
                    });
                  },
                  onSortConfChanged: (value) {
                    setState(() {
                      sortConfig = value;
                    });
                  },
                  selectHistory: selectHistory,
                  history: hostsFile.history,
                  onHistoryChanged: (history) async {
                    List<SimpleHostFileHistory> resultHistory =
                        await FileManager().getHistory(hostsFile.fileId);
                    setState(() {
                      if (history != null) {
                        selectHistory = history;
                        hostsFile.setHistory(history.path);
                      }
                      hostsFile.history = resultHistory;
                    });
                  },
                ),
                if (!hostsFile.isSave)
                  FutureBuilder(
                      future: saveTipMessage(context),
                      builder: (BuildContext context,
                          AsyncSnapshot<Widget> snapshot) {
                        if (snapshot.hasData) {
                          return snapshot.data!;
                        }
                        return const SizedBox();
                      }),
                Expanded(
                    child: editMode == EditMode.Table
                        ? _buildTable(filterHosts)
                        : _buildTextEdit())
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<MaterialBanner> saveTipMessage(BuildContext context) async {
    final bool isUseFile = hostsFile.fileId ==
        await _settingsManager.getString(settingKeyUseHostFile);
    return MaterialBanner(
      content: Text(
          "内容已更新！请确保保存您的更改，以免丢失重要信息。${isUseFile ? '\n该文件已被使用保存时需要管理员权限。' : ''}"),
      leading: const Icon(Icons.error_outline),
      actions: [
        TextButton(
          onPressed: () async {
            if (isUseFile) {
              try {
                await _fileManager.saveToHosts(hostsFile.toString());
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("保存失败")));
                return;
              }
            }
            setState(() {
              hostsFile.save(true);
            });
          },
          child: const Text('保存并生成历史'),
        ),
        TextButton(
          onPressed: () async {
            if (isUseFile) {
              try {
                await _fileManager.saveToHosts(hostsFile.toString());
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("保存失败")));
                return;
              }
            }
            setState(() {
              hostsFile.save();
            });
          },
          child: const Text('保存'),
        ),
      ],
    );
  }

  List<TableRow> tableBody(List<HostsModel> hosts) {
    return hosts.asMap().entries.map((entry) {
      final int index = entry.key;
      final it = entry.value;
      return TableRow(children: [
        Checkbox(
            value: selectHosts.contains(it),
            onChanged: (bool? newValue) {
              setState(() {
                if (selectHosts.contains(it)) {
                  selectHosts.remove(it);
                } else {
                  selectHosts.add(it);
                }
              });
            }),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => _launchUrl(it.host),
            child: Text(
              it.host,
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Switch(
                value: it.isUse,
                onChanged: (value) {
                  setState(() {
                    it.isUse = value;
                    hostsFile.updateHost(index, it);
                  });
                })),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text.rich(TextSpan(
              children: _buildTextSpans(it.hosts),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold))),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SelectableText(it.description),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              IconButton(
                  onPressed: () async {
                    List<HostsModel>? hostsModels = await Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => HostPage(hostModel: it)));
                    if (hostsModels == null) return;
                    setState(() {
                      hostsFile.updateHost(index, hostsModels.first);
                    });
                  },
                  icon: const Icon(Icons.edit)),
              const SizedBox(width: 8),
              CopyDialog(context: context, hosts: hosts, index: index),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () {
                    deleteMultiple([it]);
                  },
                  icon: const Icon(Icons.delete_outline)),
            ],
          ),
        )
      ]);
    }).toList();
  }

  void deleteMultiple(List<HostsModel> array) {
    if (array.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(array.length == 1
          ? "您确认需要删除《${array.first.host}》吗？"
          : "确认删除选中的${array.length}条记录吗？"),
      action: SnackBarAction(
          label: "确认",
          onPressed: () {
            setState(() {
              hostsFile.deleteMultiple(array);
            });
          }),
    ));
  }

  List<InlineSpan> _buildTextSpans(List<String> hosts) {
    List<InlineSpan> textSpans = [];

    for (int i = 0; i < hosts.length; i++) {
      textSpans.add(TextSpan(
        text: hosts[i],
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            _launchUrl(hosts[i]);
          },
      ));

      if (i < hosts.length - 1) {
        textSpans.add(TextSpan(
            text: ' - ',
            style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.w900)));
      }
    }

    return textSpans;
  }

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.https(url))) {
      throw Exception('Could not launch $url');
    }
  }

  Widget _buildTable(List<HostsModel> filterHosts) {
    if (filterHosts.isEmpty) {
      return Container(
        alignment: Alignment.center,
        width: double.maxFinite,
        height: double.maxFinite,
        child: const ErrorEmpty(),
      );
    } else {
      return SingleChildScrollView(
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(50),
            2: FixedColumnWidth(100),
            3: FlexColumnWidth(2),
            5: FixedColumnWidth(180),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: tableBody(filterHosts),
        ),
      );
    }
  }

  _buildTextEdit() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: TextField(
        controller: _textEditingController,
        maxLines: double.maxFinite.toInt(),
        onChanged: (value) {},
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}

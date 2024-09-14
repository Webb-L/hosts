import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
import 'package:hosts/widget/snakbar.dart';

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
      setState(() {
        hostsFile.isSave =
            hostsFile.defaultContent == _textEditingController.text;
        hostsFile.formString(_textEditingController.text);
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
                  selectHosts.clear();
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
              onChanged: (String value, String fileId) async {
                if (await _settingsManager.getString(settingKeyUseHostFile) ==
                    fileId) {
                  if (!await _fileManager.areFilesEqual(fileId)) {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(AppLocalizations.of(context)!.warning),
                            content: Text(AppLocalizations.of(context)!
                                .warning_different),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await _fileManager
                                        .saveToHosts(hostsFile.toString());
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                AppLocalizations.of(context)!
                                                    .error_save_fail)));
                                    return;
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text(AppLocalizations.of(context)!
                                    .warning_different_covering_system),
                              ),
                              TextButton(
                                onPressed: () async {
                                  setState(() {
                                    hostsFile.formString(
                                        File(FileManager.systemHostFilePath)
                                            .readAsStringSync());
                                    hostsFile.save(true);
                                    Navigator.of(context).pop();
                                  });
                                },
                                child: Text(AppLocalizations.of(context)!
                                    .warning_different_covering_current),
                              ),
                            ],
                          );
                        });
                  }
                }
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
                HomeAppBar(
                  isSave: hostsFile.isSave,
                  onOpenFile: (content) => setState(() {
                    hostsFile.formString(content);
                    hostsFile.defaultContent = content;
                    hostsFile.isUpdateHost();
                  }),
                  undoHost: () => setState(() {
                    hostsFile.undoHost();
                    _textEditingController.value =
                        TextEditingValue(text: hostsFile.toString());
                    selectHosts.clear();
                  }),
                  searchText: searchText,
                  onSearchChanged: (value) => setState(() {
                    searchText = value;
                  }),
                  advancedSettingsEnum: advancedSettingsEnum,
                  onSwitchAdvancedSettings: (AdvancedSettingsEnum value) =>
                      setState(() {
                    advancedSettingsEnum = value;
                  }),
                  editMode: editMode,
                  onSwitchMode: (value) => setState(() {
                    if (editMode == EditMode.Text) {
                      editMode = EditMode.Table;
                      hostsFile.formString(_textEditingController.text);
                      selectHosts.clear();
                    } else {
                      editMode = EditMode.Text;
                      _textEditingController.value =
                          TextEditingValue(text: hostsFile.toString());
                    }
                  }),
                  hosts: selectHosts,
                  sortConfig: sortConfig,
                  onDeletePressed: () => deleteMultiple(
                    context,
                    selectHosts.map((item) => item.host).toList(),
                    () => setState(() {
                      hostsFile.deleteMultiple(selectHosts);
                      selectHosts.clear();
                    }),
                  ),
                  isCheckedAll: hostsFile.hosts.length == selectHosts.length,
                  onCheckedAllChanged: (value) =>setState(() {
                    selectHosts.clear();
                    if (value ?? false) {
                      selectHosts.addAll(hostsFile.hosts);
                    }
                  }),
                  onSortConfChanged: (value) =>setState(() {
                    sortConfig = value;
                  }),
                  selectHistory: selectHistory,
                  history: hostsFile.history,
                  onSwitchHosts: (value) =>setState(() {
                    for (var host in selectHosts) {
                      host.isUse = value;
                    }
                  }),
                  onHistoryChanged: (history) async {
                    List<SimpleHostFileHistory> resultHistory =
                        await _fileManager.getHistory(hostsFile.fileId);
                    setState(() {
                      if (history != null) {
                        selectHistory = history;
                        hostsFile.setHistory(history.path).then((value) {
                          if (editMode != EditMode.Text) return;
                          setState(() {
                            _textEditingController.value =
                                TextEditingValue(text: hostsFile.toString());
                          });
                        });
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

    final String updateSaveTip =
        AppLocalizations.of(context)!.error_not_update_save_tip;
    final String updateSavePermissionTip = isUseFile
        ? '\n${AppLocalizations.of(context)!.error_not_update_save_permission_tip}'
        : '';
    return MaterialBanner(
      content: Text("$updateSaveTip$updateSavePermissionTip"),
      leading: const Icon(Icons.error_outline),
      actions: [
        TextButton(
          onPressed: () async {
            if (isUseFile) {
              try {
                await _fileManager.saveToHosts(hostsFile.toString());
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.error_save_fail)));
                return;
              }
            }
            setState(() {
              hostsFile.save(true);
            });
          },
          child: Text(AppLocalizations.of(context)!.save_create_history),
        ),
        TextButton(
          onPressed: () async {
            if (isUseFile) {
              try {
                await _fileManager.saveToHosts(hostsFile.toString());
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.error_save_fail)));
                return;
              }
            }
            setState(() {
              hostsFile.save();
            });
          },
          child: Text(AppLocalizations.of(context)!.save),
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
                    selectHosts.clear();
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
                      selectHosts.clear();
                    });
                  },
                  icon: const Icon(Icons.edit)),
              const SizedBox(width: 8),
              CopyDialog(context: context, hosts: hosts, index: index),
              const SizedBox(width: 8),
              IconButton(
                  onPressed: () {
                    final List<HostsModel> list = [it];
                    deleteMultiple(
                      context,
                      list.map((item) => item.host).toList(),
                      () => setState(() {
                        hostsFile.deleteMultiple(list);
                      }),
                    );
                  },
                  icon: const Icon(Icons.delete_outline)),
            ],
          ),
        )
      ]);
    }).toList();
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
    // if (!await launchUrl(Uri.https(url))) {
    //   throw Exception('Could not launch $url');
    // }
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
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }
}

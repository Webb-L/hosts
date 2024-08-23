import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hosts/enum/edit_mode_enum.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/page/host_page.dart';
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
  final List<HostsModel> selectHosts = [];
  HostsFile hostsFile = HostsFile("/etc/hosts");
  EditMode editMode = EditMode.Table;
  String searchText = "";
  Map<String, int?> sortConfig = {
    "host": null,
    "isUse": 1,
    "hosts": null,
    "description": null,
  };

  final TextEditingController _textEditingController = TextEditingController();

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
                HostsModel? hostsModel = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const HostPage()));
                if (hostsModel == null) return;
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text("添加成功")));
                setState(() {
                  hostsFile.addHost(hostsModel);
                });
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: Row(
        children: [
          HomeDrawer(onChanged: (String value) {
            setState(() {
              hostsFile = HostsFile(value);
            });
          },),
          Expanded(
            child: Column(
              children: [
                const SizedBox(height: 12),
                HomeAppBar(
                    searchText: searchText,
                    onSearchChanged: (value) {
                      setState(() {
                        searchText = value;
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
                        if (value ?? false) {
                          selectHosts.addAll(hostsFile.hosts);
                        } else {
                          selectHosts.clear();
                        }
                      });
                    },
                    onSortConfChanged: (value) {
                      setState(() {
                        sortConfig = value;
                      });
                    }),
                if (!hostsFile.isSave)
                  MaterialBanner(
                    content: const Text('内容已更新！请确保保存您的更改，以免丢失重要信息。'),
                    leading: const Icon(Icons.error_outline),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          await Process.start("pkexec", ["env"]);
                          setState(() {
                            hostsFile.isSave = true;
                          });
                        },
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                Expanded(
                    child: SingleChildScrollView(
                  child: editMode == EditMode.Table
                      ? _buildTable(filterHosts)
                      : _buildTextEdit(),
                ))
              ],
            ),
          ),
        ],
      ),
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
                  fontWeight: FontWeight.bold),
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
                    HostsModel? hostsModel = await Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => HostPage(hostModel: it)));
                    if (hostsModel == null) return;
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("更新成功")));
                    setState(() {
                      hostsFile.updateHost(index, hostsModel);
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
                  icon: const Icon(Icons.delete)),
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
      return const Align(
        alignment: Alignment.center,
        child: ErrorEmpty(),
      );
    } else {
      return Table(
        columnWidths: const {
          0: FixedColumnWidth(50),
          2: FixedColumnWidth(100),
          3: FlexColumnWidth(2),
          5: FixedColumnWidth(180),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableBody(filterHosts),
      );
    }
  }

  _buildTextEdit() {
    return TextField(
      controller: _textEditingController,
      maxLines: double.maxFinite.toInt(),
      decoration: const InputDecoration(border: InputBorder.none),
    );
  }
}

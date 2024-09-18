import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/widget/app_bar/home_app_bar.dart';
import 'package:hosts/widget/dialog/link_dialog.dart';
import 'package:hosts/widget/host_table.dart';
import 'package:hosts/widget/snakbar.dart';
import 'package:path/path.dart' as p;

class SimpleHomePage extends StatefulWidget {
  final String fileContent;

  const SimpleHomePage({super.key, required this.fileContent});

  @override
  State<SimpleHomePage> createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends State<SimpleHomePage> {
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
    setState(() {
      hostsFile.formString(widget.fileContent);
      hostsFile.defaultContent = widget.fileContent;
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
      body: Column(
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
            onCheckedAllChanged: (value) => setState(() {
              selectHosts.clear();
              if (value ?? false) {
                selectHosts.addAll(hostsFile.hosts);
              }
            }),
            onSortConfChanged: (value) => setState(() {
              sortConfig = value;
            }),
            selectHistory: selectHistory,
            history: hostsFile.history,
            onSwitchHosts: (value) => setState(() {
              for (var host in selectHosts) {
                host.isUse = value;
              }
            }),
            onHistoryChanged: (history) {},
          ),
          if (!hostsFile.isSave)
            FutureBuilder(
                future: saveTipMessage(context),
                builder:
                    (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                  if (snapshot.hasData) {
                    return snapshot.data!;
                  }
                  return const SizedBox();
                }),
          buildHostTableOrTextEdit(
            hostsFile.filterHosts(searchText, sortConfig),
          )
        ],
      ),
    );
  }

  Future<MaterialBanner> saveTipMessage(BuildContext context) async {
    return MaterialBanner(
      content: Text(AppLocalizations.of(context)!.error_not_update_save_tip),
      leading: const Icon(Icons.error_outline),
      actions: [
        TextButton(
          onPressed: () async {
            final String hostContent = hostsFile.toString();
            if (!kIsWeb) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text("保存"),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: SelectableText(hostContent),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => writeClipboard(
                                    'echo "$hostContent" > /etc/hosts',
                                    hostContent,
                                    context,
                                  ),
                              child: const Text("Linux(echo)")),
                          TextButton(
                              onPressed: () {
                                final String systemHostPath = p.joinAll([
                                  "C:",
                                  "Windows",
                                  "System32",
                                  "drivers",
                                  "etc",
                                  "hosts"
                                ]);
                                final String content = hostContent
                                    .split("\n")
                                    .map((item) => 'echo "$item"')
                                    .join("\n");
                                writeClipboard(
                                  '(\n$content\n) > $systemHostPath',
                                  hostContent,
                                  context,
                                );
                              },
                              child: const Text("Windows(echo)")),
                          TextButton(
                              onPressed: () => writeClipboard(
                                    'echo "$hostContent" > /etc/hosts',
                                    hostContent,
                                    context,
                                  ),
                              child: const Text("MacOS(echo)")),
                        ],
                      ));
              return;
            }

            final File file = File("/etc/hosts");

            try {
              file.writeAsStringSync("", mode: FileMode.append);
            } on PathAccessException catch (e) {
              print(e);
            }
            print(await File("/etc/hosts")
                .writeAsString("", mode: FileMode.append));
            try {
              // await _fileManager.saveToHosts(hostsFile.toString());
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text(AppLocalizations.of(context)!.error_save_fail)));
              return;
            }
            setState(() {
              // hostsFile.save();
            });
          },
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  void writeClipboard(
      String hostContent, String defaultContent, BuildContext context) {
    Clipboard.setData(ClipboardData(text: hostContent)).then((_) {
      setState(() {
        hostsFile.defaultContent = defaultContent;
        hostsFile.isUpdateHost();
        Navigator.pop(context);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.copy_to_tip),
        ),
      );
    });
  }

  Widget buildHostTableOrTextEdit(List<HostsModel> filterHosts) {
    return Expanded(
        child: editMode == EditMode.Table
            ? HostTable(
                hosts: filterHosts,
                selectHosts: selectHosts,
                onChecked: (index, host) {
                  setState(() {
                    if (selectHosts.contains(host)) {
                      selectHosts.remove(host);
                    } else {
                      selectHosts.add(host);
                    }
                  });
                },
                onLink: (index, host) async {
                  final Map<String,List<String>>? result = await linkDialog(context, hostsFile.hosts, host);
                  if (result==null) return;
                  print(result);
                },
                onEdit: (index, host) async {
                  List<HostsModel>? hostsModels =
                      await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => HostPage(hostModel: host),
                    ),
                  );
                  if (hostsModels == null) return;
                  setState(() {
                    hostsFile.updateHost(index, hostsModels.first);
                    selectHosts.clear();
                  });
                },
                onDelete: (hosts) {
                  deleteMultiple(
                    context,
                    hosts.map((item) => item.host).toList(),
                    () => setState(() {
                      hostsFile.deleteMultiple(hosts);
                    }),
                  );
                },
                onToggleUse: (index, host) {
                  setState(() {
                    hostsFile.updateHost(index, host);
                    selectHosts.clear();
                  });
                },
                onLaunchUrl: (url) {
                  // Uncomment and implement the URL launching logic if needed
                  // if (!await launchUrl(Uri.https(url))) {
                  //   throw Exception('Could not launch $url');
                  // }
                },
              )
            : Padding(
                padding: const EdgeInsets.only(left: 16),
                child: TextField(
                  controller: _textEditingController,
                  maxLines: double.maxFinite.toInt(),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ));
  }
}

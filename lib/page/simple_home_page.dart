import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/page/home_base_page.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/widget/app_bar/home_app_bar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class SimpleHomePage extends BaseHomePage {
  final String filePath;

  const SimpleHomePage({super.key, required this.filePath});

  @override
  _SimpleHomePageState createState() => _SimpleHomePageState();
}

class _SimpleHomePageState extends BaseHomePageState<SimpleHomePage> {
  @override
  void initState() {
    if (widget.filePath.isNotEmpty) {
      final String fileContent = File(widget.filePath).readAsStringSync();
      setState(() {
        hostsFile.formString(fileContent);
        hostsFile.defaultContent = fileContent;
        filterHosts.clear();
        filterHosts.addAll(hostsFile.filterHosts(searchText, sortConfig));
      });
    }
    textEditingController.addListener(() {
      setState(() {
        hostsFile.formString(textEditingController.text);
        hostsFile.isUpdateHost();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(context),
      body: Column(
        children: [
          HomeAppBar(
            isSave: hostsFile.isSave,
            onOpenFile: onOpenFile,
            undoHost: undoHost,
            searchText: searchText,
            onSearchChanged: onSearchChanged,
            advancedSettingsEnum: advancedSettingsEnum,
            onSwitchAdvancedSettings: onSwitchAdvancedSettings,
            editMode: editMode,
            onSwitchMode: onSwitchMode,
            hosts: selectHosts,
            sortConfig: sortConfig,
            onDeletePressed: onDeletePressed,
            isCheckedAll: hostsFile.hosts.length == selectHosts.length,
            onCheckedAllChanged: onCheckedAllChanged,
            onSortConfChanged: onSortConfChanged,
            selectHistory: selectHistory,
            history: hostsFile.history,
            onSwitchHosts: onSwitchHosts,
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
          buildHostTableOrTextEdit(filterHosts)
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
            if (kIsWeb) {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        title: const Text("保存"),
                        content: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: SelectableText(hostContent),
                        ),
                        actions: [
                          // TODO 注意：命令执行漏洞
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

            final File file = File(widget.filePath);

            try {
              await file.writeAsString(hostContent);
            } on PathAccessException catch (e) {
              try {
                final Directory cacheDirectory =
                    await getApplicationCacheDirectory();
                final File cacheFile =
                    File(p.join(cacheDirectory.path, 'hosts'));
                await cacheFile.writeAsString(hostContent);

                FileManager().writeFileWithAdminPrivileges(
                    cacheFile.path, widget.filePath);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(AppLocalizations.of(context)!.error_save_fail)));
                return;
              }
            }

            setState(() {
              hostsFile.defaultContent = hostContent;
              hostsFile.isUpdateHost();
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
}

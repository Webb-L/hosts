import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/home_base_page.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/util/settings_manager.dart';
import 'package:hosts/widget/app_bar/home_app_bar.dart';
import 'package:hosts/widget/home_drawer.dart';
import 'package:hosts/widget/host_text_editing_controller.dart';

class HomePage extends BaseHomePage {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState(); // 返回 _HomePageState
}

class _HomePageState extends BaseHomePageState<HomePage> {
  final SettingsManager _settingsManager = SettingsManager();
  final FileManager _fileManager = FileManager();

  @override
  void initState() {
    textEditingController.addListener(() {
      setState(() {
        hostsFile.isSave =
            hostsFile.defaultContent == textEditingController.text;
        hostsFile.formString(textEditingController.text);
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: buildFloatingActionButton(context),
      body: Row(
        children: [
          if (advancedSettingsEnum == AdvancedSettingsEnum.Close)
            buildHomeDrawer(context),
          Expanded(
            child: Column(
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
                  onHistoryChanged: (history) async {
                    List<SimpleHostFileHistory> resultHistory =
                        await _fileManager.getHistory(hostsFile.fileId);
                    setState(() {
                      if (history != null) {
                        selectHistory = history;
                        hostsFile.setHistory(history.path).then((value) {
                          if (editMode != EditMode.Text) return;
                          updateTextEditingController();
                        });
                      }
                      hostsFile.history = resultHistory;
                      syncFilterHosts();
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
                buildHostTableOrTextEdit(filterHosts)
              ],
            ),
          ),
        ],
      ),
    );
  }

  HomeDrawer buildHomeDrawer(BuildContext context) {
    return HomeDrawer(
      isSave: hostsFile.isSave,
      onChanged: (String value, String fileId) async {
        if (await _settingsManager.getString(settingKeyUseHostFile) == fileId) {
          if (!await _fileManager.areFilesEqual(fileId)) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.warning),
                    content:
                        Text(AppLocalizations.of(context)!.warning_different),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          try {
                            await _fileManager
                                .saveToHosts(hostsFile.toString());
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(AppLocalizations.of(context)!
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
          hostsFile = HostsFile(value, fileId);
          if (editMode == EditMode.Text) {
            updateTextEditingController();
          } else {
            syncFilterHosts();
          }
        });
      },
    );
  }

  void updateTextEditingController() {
    textEditingController.dispose();

    textEditingController = HostTextEditingController()
      ..text = hostsFile.toString()
      ..addListener(() {
        setState(() {
          hostsFile.isSave =
              hostsFile.defaultContent == textEditingController.text;
          hostsFile.formString(textEditingController.text);
        });
      });
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
}

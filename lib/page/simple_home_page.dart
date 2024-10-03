import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/page/home_base_page.dart';
import 'package:hosts/widget/app_bar/home_app_bar.dart';

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

    if (kIsWeb) {
      setState(() {
        hostsFile.formString("");
        hostsFile.defaultContent = "";
      });
    }

    textEditingController.addListener(() {
      setState(() {
        hostsFile.isUpdateHostWithText(textEditingController.text);
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
          onPressed: () => saveHost(widget.filePath, hostsFile.toString()),
          child: Text(AppLocalizations.of(context)!.save),
        ),
      ],
    );
  }

  @override
  void onKeySaveChange() {
    saveHost(widget.filePath, hostsFile.toString());
  }
}

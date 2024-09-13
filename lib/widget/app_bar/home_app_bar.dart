import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/history_page.dart';
import 'package:hosts/widget/dialog/copy_multiple_dialog.dart';
import 'package:hosts/widget/text_field/search_text_field.dart';

class HomeAppBar extends StatelessWidget {
  final bool isSave;
  final VoidCallback undoHost;
  final String searchText;
  final ValueChanged<String> onSearchChanged;
  final AdvancedSettingsEnum advancedSettingsEnum;
  final ValueChanged<AdvancedSettingsEnum> onSwitchAdvancedSettings;
  final EditMode editMode;
  final ValueChanged<EditMode> onSwitchMode;
  final List<HostsModel> hosts;
  final Map<String, int?> sortConfig;
  final VoidCallback? onDeletePressed;
  final bool isCheckedAll;
  final ValueChanged<bool?> onCheckedAllChanged;
  final ValueChanged<Map<String, int?>> onSortConfChanged;
  final SimpleHostFileHistory? selectHistory;
  final List<SimpleHostFileHistory> history;
  final ValueChanged<bool> onSwitchHosts;
  final ValueChanged<SimpleHostFileHistory?> onHistoryChanged;

  const HomeAppBar({
    super.key,
    required this.isSave,
    required this.undoHost,
    required this.searchText,
    required this.onSearchChanged,
    required this.advancedSettingsEnum,
    required this.onSwitchAdvancedSettings,
    required this.editMode,
    required this.onSwitchMode,
    required this.hosts,
    required this.sortConfig,
    required this.onDeletePressed,
    required this.isCheckedAll,
    required this.onCheckedAllChanged,
    required this.onSortConfChanged,
    required this.selectHistory,
    required this.history,
    required this.onSwitchHosts,
    required this.onHistoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  onSwitchAdvancedSettings(
                    advancedSettingsEnum == AdvancedSettingsEnum.Close
                        ? AdvancedSettingsEnum.Open
                        : AdvancedSettingsEnum.Close,
                  );
                },
                icon: const Icon(Icons.settings),
                tooltip: AppLocalizations.of(context)!.advanced_settings,
              ),
              const SizedBox(width: 10),
              if (editMode == EditMode.Table)
                SizedBox(
                  width: 430,
                  child: SearchTextField(
                    text: searchText,
                    onChanged: onSearchChanged,
                  ),
                ),
              const Expanded(child: SizedBox()),
              Row(
                children: [
                  if (hosts.isNotEmpty && editMode == EditMode.Table)
                    Switch(
                      value: true,
                      onChanged: (value) => onSwitchHosts(true),
                    ),
                  if (hosts.isNotEmpty && editMode == EditMode.Table)
                    Switch(
                      value: false,
                      onChanged: (value) => onSwitchHosts(false),
                    ),
                  if (!isSave)
                    IconButton(
                      onPressed: undoHost,
                      icon: const Icon(Icons.undo),
                      tooltip: AppLocalizations.of(context)!.reduction,
                    ),
                  if (hosts.isNotEmpty && editMode == EditMode.Table)
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  CopyMultipleDialog(hosts: hosts));
                        },
                        tooltip: AppLocalizations.of(context)!.copy_selected,
                        icon: const Icon(Icons.copy)),
                  if (hosts.isNotEmpty && editMode == EditMode.Table)
                    IconButton(
                        onPressed: onDeletePressed,
                        tooltip: AppLocalizations.of(context)!.delete_selected,
                        icon: const Icon(Icons.delete_outline)),
                  if (history.isNotEmpty)
                    IconButton(
                      onPressed: () async {
                        SimpleHostFileHistory? resultHistory =
                            await showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return HistoryPage(
                                selectHistory: selectHistory, history: history);
                          },
                        );
                        if (resultHistory != null) {
                          onHistoryChanged(resultHistory);
                          return;
                        }
                        onHistoryChanged(null);
                      },
                      icon: const Icon(Icons.history),
                    ),
                  _buildEditModeButton(context),
                ],
              )
            ],
          ),
        ),
        if (editMode == EditMode.Table)
          Table(
            columnWidths: const {
              0: FixedColumnWidth(50),
              2: FixedColumnWidth(100),
              3: FlexColumnWidth(2),
              5: FixedColumnWidth(180),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [tableHeader(context)],
          )
      ],
    );
  }

  IconButton _buildEditModeButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        if (editMode == EditMode.Text) {
          onSwitchMode(EditMode.Table);
        } else {
          onSwitchMode(EditMode.Text);
        }
      },
      tooltip: editMode == EditMode.Text
          ? AppLocalizations.of(context)!.table
          : AppLocalizations.of(context)!.text,
      icon: Icon(
        editMode == EditMode.Text
            ? Icons.table_rows_outlined
            : Icons.text_snippet_outlined,
      ),
    );
  }

  TableRow tableHeader(BuildContext context) {
    return TableRow(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Checkbox(
                value: hosts.isNotEmpty && isCheckedAll,
                onChanged: onCheckedAllChanged)),
        tableHeaderItem("host", AppLocalizations.of(context)!.ip_address),
        tableHeaderItem("isUse", AppLocalizations.of(context)!.status),
        tableHeaderItem("hosts", AppLocalizations.of(context)!.domain),
        tableHeaderItem("description", AppLocalizations.of(context)!.remark),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(AppLocalizations.of(context)!.action,
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  GestureDetector tableHeaderItem(String columnName, String label) {
    return GestureDetector(
      onTap: () {
        if (sortConfig[columnName] == null) {
          sortConfig[columnName] = 1;
        } else if (sortConfig[columnName] == 1) {
          sortConfig[columnName] = 2;
        } else if (sortConfig[columnName] == 2) {
          sortConfig[columnName] = null;
        }
        onSortConfChanged(sortConfig);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            if (sortConfig[columnName] == null)
              const SizedBox()
            else
              Icon(
                sortConfig[columnName] == 2
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                size: 16.0,
              ),
          ],
        ),
      ),
    );
  }
}

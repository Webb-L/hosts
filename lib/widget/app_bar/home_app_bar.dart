import 'package:flutter/material.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/widget/dialog/copy_multiple_dialog.dart';
import 'package:hosts/widget/text_field/search_text_field.dart';

class HomeAppBar extends StatelessWidget {
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

  const HomeAppBar(
      {super.key,
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
      required this.onSortConfChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
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
                icon: Icon(advancedSettingsEnum == AdvancedSettingsEnum.Close
                    ? Icons.close
                    : Icons.settings),
                tooltip: "高级设置",
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
                    IconButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) =>
                                  CopyMultipleDialog(hosts: hosts));
                        },
                        tooltip: "复制选中",
                        icon: const Icon(Icons.copy)),
                  if (hosts.isNotEmpty && editMode == EditMode.Table)
                    IconButton(
                        onPressed: onDeletePressed,
                        tooltip: "删除选中",
                        icon: const Icon(Icons.delete)),
                  _buildEditModeButton(),
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
            children: [tableHeader()],
          )
      ],
    );
  }

  IconButton _buildEditModeButton() {
    return IconButton(
      onPressed: () {
        if (editMode == EditMode.Text) {
          onSwitchMode(EditMode.Table);
        } else {
          onSwitchMode(EditMode.Text);
        }
      },
      tooltip: editMode == EditMode.Text ? "表格" : "文本",
      icon: Icon(
        editMode == EditMode.Text
            ? Icons.table_rows_outlined
            : Icons.text_snippet_outlined,
      ),
    );
  }

  TableRow tableHeader() {
    return TableRow(
      children: [
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Checkbox(
                value: hosts.isNotEmpty && isCheckedAll,
                onChanged: onCheckedAllChanged)),
        tableHeaderItem("host", "IP地址"),
        tableHeaderItem("isUse", "状态"),
        tableHeaderItem("hosts", "域名"),
        tableHeaderItem("description", "备注"),
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('操作', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  size: 16.0),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hosts/enum/edit_mode_enum.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/widget/dialog/copy_multiple_dialog.dart';
import 'package:hosts/widget/text_field/search_text_field.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String searchText;
  final ValueChanged<String> onSearchChanged;
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
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: const Text("Hosts Editor"),
      actions: [
        if (editMode == EditMode.Table)
          SizedBox(
            width: 230,
            child: SearchTextField(
              text: searchText,
              onChanged: onSearchChanged,
            ),
          ),
        _buildEditModeButton(),
        if (hosts.isNotEmpty && editMode == EditMode.Table)
          IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => CopyMultipleDialog(hosts: hosts));
              },
              tooltip: "复制选中",
              icon: const Icon(Icons.copy)),
        if (hosts.isNotEmpty && editMode == EditMode.Table)
          IconButton(
              onPressed: onDeletePressed,
              tooltip: "删除选中",
              icon: const Icon(Icons.delete)),
      ],
      bottom: editMode == EditMode.Table
          ? PreferredSize(
              preferredSize: const Size(double.maxFinite, 48),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(50),
                  2: FixedColumnWidth(100),
                  3: FlexColumnWidth(2),
                  5: FixedColumnWidth(180),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [tableHeader()],
              ))
          : null,
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
            child:
                Checkbox(value: isCheckedAll, onChanged: onCheckedAllChanged)),
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

  @override
  Size get preferredSize =>
      Size.fromHeight(56.0 + (editMode == EditMode.Table ? 48 : 0));
}

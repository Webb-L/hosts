import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/widget/dialog/copy_dialog.dart';
import 'package:hosts/widget/error/error_empty.dart';

class HostTable extends StatelessWidget {
  final List<HostsModel> hosts;
  final List<HostsModel> selectHosts;
  final Function(int, HostsModel) onEdit;
  final Function(int, HostsModel) onLink;
  final Function(int, HostsModel) onChecked;
  final Function(List<HostsModel>) onDelete;
  final Function(List<HostsModel>) onToggleUse;
  final Function(String) onLaunchUrl;

  const HostTable({
    super.key,
    required this.hosts,
    required this.selectHosts,
    required this.onChecked,
    required this.onEdit,
    required this.onLink,
    required this.onDelete,
    required this.onToggleUse,
    required this.onLaunchUrl,
  });

  List<TableRow> tableBody(BuildContext context) {
    return hosts.asMap().entries.map((entry) {
      final int index = entry.key;
      final it = entry.value;
      return TableRow(children: [
        Checkbox(
          value: selectHosts.contains(it),
          onChanged: (bool? newValue) => onChecked(index, it),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => onLaunchUrl(it.host),
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
              it.isUse = value;

              final List<HostsModel> updateUseHosts = [it];
              void updateHostStates(List<String> hostNames, bool isUse) {
                for (var tempHost in hosts.where((item) => hostNames.contains(item.host))) {
                  tempHost.isUse = isUse;
                  updateUseHosts.add(tempHost);
                }
              }

              // 相同
              updateHostStates(it.config["same"] ?? [], value);
              // 相反
              updateHostStates(it.config["contrary"] ?? [], !value);

              onToggleUse(updateUseHosts);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text.rich(TextSpan(
              children: _buildTextSpans(it.hosts, context),
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
                onPressed: () => onEdit(index, it),
                icon: const Icon(Icons.edit),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => onDelete([it]),
                icon: const Icon(Icons.delete_outline),
              ),
              const SizedBox(width: 8),
              buildMoreButton(context, index, it),
            ],
          ),
        )
      ]);
    }).toList();
  }

  List<InlineSpan> _buildTextSpans(List<String> hosts, BuildContext context) {
    List<InlineSpan> textSpans = [];

    for (int i = 0; i < hosts.length; i++) {
      textSpans.add(TextSpan(
        text: hosts[i],
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            onLaunchUrl(hosts[i]);
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

  Widget buildMoreButton(BuildContext context, int index, HostsModel host) {
    return PopupMenuButton<int>(
      style: OutlinedButton.styleFrom(
        minimumSize: Size.zero,
        padding: EdgeInsets.zero,
      ),
      onSelected: (value) async {
        switch (value) {
          case 1:
            onLink(index, host);
            break;
          case 2:
            copyDialog(context, hosts, index);
            break;
        }
      },
      // IconButton(
      //   onPressed: () => onLink(index, it),
      //   icon: const Icon(Icons.link),
      //   tooltip: "关联",
      // ),
      // const SizedBox(width: 8),
      // CopyDialog(context: context, hosts: hosts, index: index),
      itemBuilder: (BuildContext context) {
        List<Map<String, Object>> list = [
          {"icon": Icons.link, "text": "关联", "value": 1},
          {
            "icon": Icons.copy,
            "text": AppLocalizations.of(context)!.copy,
            "value": 2
          },
        ];

        return list.map((item) {
          return PopupMenuItem<int>(
            value: int.parse(item["value"].toString()),
            child: Row(
              children: [
                Icon(item["icon"]! as IconData),
                const SizedBox(width: 8),
                Text(item["text"]!.toString()),
              ],
            ),
          );
        }).toList();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (hosts.isEmpty) {
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
            5: FixedColumnWidth(150),
          },
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: tableBody(context),
        ),
      );
    }
  }
}

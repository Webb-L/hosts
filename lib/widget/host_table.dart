import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/widget/dialog/copy_dialog.dart';
import 'package:hosts/widget/dialog/test_dialog.dart';
import 'package:hosts/widget/host_base_view.dart';

class HostTable extends HostBaseView {
  const HostTable({
    super.key,
    required super.hosts,
    required super.selectHosts,
    required super.onEdit,
    required super.onLink,
    required super.onChecked,
    required super.onDelete,
    required super.onToggleUse,
    required super.onLaunchUrl,
  });

  List<TableRow> tableBody(BuildContext context) {
    return hosts.asMap().entries.map((entry) {
      final int index = entry.key;
      final it = entry.value;

      bool isLink = false;
      if (it.config.isNotEmpty) {
        isLink = it.config["same"] != null && it.config["contrary"] != null;
      }
      return TableRow(children: [
        Checkbox(
          value: selectHosts.contains(it),
          onChanged: (bool? newValue) => onChecked(index, it),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => onLaunchUrl(it.host),
            child: Text.rich(TextSpan(
              children: [
                if (isLink)
                  WidgetSpan(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.link,
                      color: Theme.of(context).colorScheme.primary,
                      size: 18,
                    ),
                  )),
                TextSpan(
                  text: it.host,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            )),
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
                for (var tempHost
                    in hosts.where((item) => hostNames.contains(item.host))) {
                  tempHost.isUse = isUse;
                  updateUseHosts.add(tempHost);
                }
              }

              // 相同
              if (it.config["same"] != null) {
                updateHostStates(
                    (it.config["same"] as List<dynamic>).cast<String>(), value);
              }
              // 相反
              if (it.config["contrary"] != null) {
                updateHostStates(
                    (it.config["contrary"] as List<dynamic>).cast<String>(),
                    !value);
              }

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
            mainAxisAlignment: MainAxisAlignment.end,
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
      onSelected: (value) async {
        switch (value) {
          case 1:
            onLink(index, host);
            break;
          case 2:
            testDialog(context, host);
            break;
          case 3:
            copyDialog(context, hosts, index);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        List<Map<String, Object>> list = [
          {
            "icon": Icons.link,
            "text": AppLocalizations.of(context)!.link,
            "value": 1
          },
          {
            "icon": Icons.sensors,
            "text": AppLocalizations.of(context)!.test,
            "value": 2
          },
          {
            "icon": Icons.copy,
            "text": AppLocalizations.of(context)!.copy,
            "value": 3
          },
        ];

        return list
            .where((item) => !(item["value"] == 2 && kIsWeb))
            .map((item) {
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
    return SingleChildScrollView(
      child: Table(
        columnWidths: const {
          0: FixedColumnWidth(50),
          2: FixedColumnWidth(100),
          3: FlexColumnWidth(2),
          5: FixedColumnWidth(180),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: tableBody(context),
      ),
    );
  }
}

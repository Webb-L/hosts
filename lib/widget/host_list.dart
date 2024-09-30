import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/widget/dialog/copy_dialog.dart';
import 'package:hosts/widget/dialog/test_dialog.dart';
import 'package:hosts/widget/host_base_view.dart';

class HostList extends HostBaseView {
  const HostList({
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: hosts.length,
      itemBuilder: (context, index) {
        final HostsModel it = hosts[index];
        return InkWell(
          onTap: () => onEdit(index, it),
          child: ListItem(
            host: it,
            onSwitchChanged: (value) {
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
            onCheckChanged: (value) => onChecked(index, it),
            trailing: buildMoreButton(context, index, it),
            isChecked: selectHosts.contains(it),
          ),
        );
      },
    );
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
          case 4:
            onDelete([host]);
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
          {"icon": Icons.sensors, "text": "测试", "value": 2},
          {
            "icon": Icons.copy,
            "text": AppLocalizations.of(context)!.copy,
            "value": 3
          },
          {"icon": Icons.delete_outline, "text": "删除", "value": 4},
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
}

class ListItem extends StatelessWidget {
  final bool isChecked;
  final HostsModel host;
  final ValueChanged<bool> onSwitchChanged;
  final ValueChanged<bool?> onCheckChanged;
  final Widget trailing;

  const ListItem(
      {super.key,
      required this.host,
      required this.onSwitchChanged,
      required this.onCheckChanged,
      required this.isChecked,
      required this.trailing});

  @override
  Widget build(BuildContext context) {
    bool isLink = false;
    if (host.config.isNotEmpty) {
      isLink = host.config["same"] != null && host.config["contrary"] != null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: isChecked,
            onChanged: onCheckChanged,
          ),
          const SizedBox(width: 16),
          Switch(
            value: host.isUse,
            onChanged: onSwitchChanged,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (host.description.isNotEmpty)
                  Text(
                    host.description,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                const SizedBox(height: 4.0),
                Text.rich(TextSpan(
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
                      text: host.host,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                )),
                const SizedBox(height: 4.0),
                Text.rich(TextSpan(
                    children: _buildTextSpans(host.hosts, context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                        fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }

  List<InlineSpan> _buildTextSpans(List<String> hosts, BuildContext context) {
    List<InlineSpan> textSpans = [];

    for (int i = 0; i < hosts.length; i++) {
      textSpans.add(TextSpan(
        text: hosts[i],
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // onLaunchUrl(hosts[i]);
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
}

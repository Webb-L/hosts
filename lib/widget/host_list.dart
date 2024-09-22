import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/widget/dialog/copy_dialog.dart';
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
              overline: it.description,
              status: Switch(
                value: it.isUse,
                onChanged: (value) {
                  it.isUse = value;

                  final List<HostsModel> updateUseHosts = [it];
                  void updateHostStates(List<String> hostNames, bool isUse) {
                    for (var tempHost in hosts
                        .where((item) => hostNames.contains(item.host))) {
                      tempHost.isUse = isUse;
                      updateUseHosts.add(tempHost);
                    }
                  }

                  // 相同
                  if (it.config["same"] != null) {
                    updateHostStates(
                        (it.config["same"] as List<dynamic>).cast<String>(),
                        value);
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
              title: it.host,
              subtitle: it.hosts.join(" - "),
              leading: Checkbox(
                value: selectHosts.contains(it),
                onChanged: (bool? newValue) => onChecked(index, it),
              ),
              trailing: buildMoreButton(context, index, it)),
        );
      },
    );
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
          case 3:
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
          {
            "icon": Icons.copy,
            "text": AppLocalizations.of(context)!.copy,
            "value": 2
          },
          {"icon": Icons.delete_outline, "text": "删除", "value": 3},
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
  final Widget leading;
  final Widget status;
  final String overline;
  final String title;
  final String subtitle;
  final Widget trailing;

  const ListItem({
    super.key,
    required this.leading,
    required this.status,
    required this.overline,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          leading,
          const SizedBox(width: 16),
          status,
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (overline.isNotEmpty)
                  Text(
                    overline,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                const SizedBox(height: 4.0),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
          const SizedBox(width: 7),
        ],
      ),
    );
  }
}

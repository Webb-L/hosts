import 'package:flutter/material.dart';
import 'package:hosts/model/host_file.dart';

Future<Map<String, List<String>>?> linkDialog(
    BuildContext context, List<HostsModel> hosts, HostsModel host) {
  final List<HostsModel> filterHosts =
      hosts.where((item) => item != host).toList();
  // 相同
  final List<HostsModel> sameCheckedHosts = [];
  final List<HostsModel> sameHosts =
      filterHosts.where((item) => !sameCheckedHosts.contains(item)).toList();
  // 相反
  final List<HostsModel> contraryCheckedHosts = [];
  final List<HostsModel> contraryHosts = filterHosts
      .where((item) => !contraryCheckedHosts.contains(item))
      .toList();

  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
            title: const Text("关联"),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildTitle(host, "相反", context),
                  const SizedBox(height: 8),
                  _buildHostList(
                    context,
                    contraryHosts,
                    contraryCheckedHosts,
                    (contraryHost) {
                      setState(() {
                        if (!contraryCheckedHosts.contains(contraryHost)) {
                          contraryCheckedHosts.add(contraryHost);
                        } else {
                          contraryCheckedHosts.remove(contraryHost);
                        }
                        sameHosts.clear();
                        sameHosts.addAll(filterHosts
                            .where(
                                (item) => !contraryCheckedHosts.contains(item))
                            .toList());
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  _buildTitle(host, "相同", context),
                  const SizedBox(height: 8),
                  _buildHostList(
                    context,
                    sameHosts,
                    sameCheckedHosts,
                    (sameHost) {
                      setState(() {
                        if (!sameCheckedHosts.contains(sameHost)) {
                          sameCheckedHosts.add(sameHost);
                        } else {
                          sameCheckedHosts.remove(sameHost);
                        }
                        contraryHosts.clear();
                        contraryHosts.addAll(filterHosts
                            .where((item) => !sameCheckedHosts.contains(item))
                            .toList());
                      });
                    },
                  ),
                ],
              );
            }),
            actions: [
              TextButton(
                onPressed: () {
                  if (contraryCheckedHosts.isEmpty &&
                      sameCheckedHosts.isEmpty) {
                    Navigator.of(context).pop();
                    return;
                  }
                  Navigator.of(context).pop({
                    "contrary":
                        contraryCheckedHosts.map((item) => item.host).toList(),
                    "same": sameCheckedHosts.map((item) => item.host).toList(),
                  });
                },
                child: const Text("确认"),
              ),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text("取消")),
            ],
          ));
}

Widget _buildHostList(BuildContext context, List<HostsModel> hosts,
    List<HostsModel> checkedHosts, Function(HostsModel) onTapCallback) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: SingleChildScrollView(
      child: Wrap(
        spacing: 10.0,
        children: List<Widget>.generate(hosts.length, (index) {
          final HostsModel host = hosts[index];
          return InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () => onTapCallback(host),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IgnorePointer(
                  child: Checkbox(
                    value: checkedHosts.contains(host),
                    onChanged: (bool? value) {}, // Keep Checkbox disabled
                  ),
                ),
                Text(host.host),
                const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    ),
  );
}

RichText _buildTitle(HostsModel host, String text, BuildContext context) {
  return RichText(
    text: TextSpan(text: "当 ", children: [
      TextSpan(
        text: host.host,
        style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary),
      ),
      const TextSpan(text: " 状态变化时，下列数据切换为"),
      TextSpan(
        text: " $text ",
        style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Theme.of(context).colorScheme.primary),
      ),
      const TextSpan(text: "状态：")
    ]),
  );
}

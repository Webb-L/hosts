import 'package:flutter/material.dart';
import 'package:hosts/model/host_file.dart';

Future<Map<String, List<String>>?> linkDialog(
    BuildContext context, List<HostsModel> hosts, HostsModel host) {
  bool isInitSameHosts = false;
  bool isInitContraryHosts = false;

  final List<String> filterHosts =
      hosts.where((item) => item != host).map((item) => item.host).toList();
  // 相同
  final List<String> sameCheckedHosts = [];

  // 相反
  final List<String> contraryCheckedHosts = [];

  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final List<String> sameHosts = filterHosts
            .where((item) => !sameCheckedHosts.contains(item))
            .toList();
        final List<String> contraryHosts = filterHosts
            .where((item) => !contraryCheckedHosts.contains(item))
            .toList();

        return AlertDialog(
          title: const Text("关联"),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            setState(() {
              if (host.config["same"] != null && !isInitSameHosts) {
                sameCheckedHosts.clear();
                sameCheckedHosts.addAll(
                    (host.config["same"] as List<dynamic>).cast<String>());
                contraryHosts.clear();
                contraryHosts.addAll(filterHosts
                    .where((item) => !sameCheckedHosts.contains(item))
                    .toList());
                isInitSameHosts = true;
              }

              if (host.config["contrary"] != null && !isInitContraryHosts) {
                contraryCheckedHosts.clear();
                contraryCheckedHosts.addAll(
                    (host.config["contrary"] as List<dynamic>).cast<String>());
                sameHosts.clear();
                sameHosts.addAll(filterHosts
                    .where((item) => !contraryCheckedHosts.contains(item))
                    .toList());
                isInitContraryHosts = true;
              }
            });

            return SingleChildScrollView(
              child: Column(
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
              ),
            );
          }),
          actions: [
            TextButton(
              onPressed: () {
                if (contraryCheckedHosts.isEmpty && sameCheckedHosts.isEmpty) {
                  Navigator.of(context).pop();
                  return;
                }
                Navigator.of(context).pop({
                  "contrary": contraryCheckedHosts,
                  "same": sameCheckedHosts,
                });
              },
              child: const Text("确认"),
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text("取消")),
          ],
        );
      });
}

Widget _buildHostList(BuildContext context, List<String> hosts,
    List<String> checkedHosts, Function(String) onTapCallback) {
  return SizedBox(
    width: MediaQuery.of(context).size.width,
    child: Wrap(
      spacing: 10.0,
      children: List<Widget>.generate(hosts.length, (index) {
        final String host = hosts[index];
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
              Text(host),
              const SizedBox(width: 8),
            ],
          ),
        );
      }),
    ),
  );
}

RichText _buildTitle(HostsModel host, String text, BuildContext context) {
  return RichText(
    text: TextSpan(
      text: "当 ",
      children: [
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
        const TextSpan(text: "状态："),
      ],
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}

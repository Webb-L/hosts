import 'package:flutter/material.dart';
import 'package:hosts/model/host_file.dart';

Future<void> linkDialog(
    BuildContext context, List<HostsModel> hosts, HostsModel host) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("关联"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                RichText(
                  text: TextSpan(text: "当 ", children: [
                    TextSpan(
                      text: host.host,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const TextSpan(text: " 状态变化时，下列数据切换为"),
                    TextSpan(
                      text: " 相反 ",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const TextSpan(text: "状态：")
                  ]),
                ),
                const SizedBox(height: 8),
                Expanded(
                    child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10.0,
                      children: List<Widget>.generate(hosts.length, (index) {
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: false,
                              onChanged: (bool? value) {},
                            ),
                            Text(hosts[index].host),
                          ],
                        );
                      }),
                    ),
                  ),
                )),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(text: "当 ", children: [
                    TextSpan(
                      text: host.host,
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const TextSpan(text: " 状态变化时，下列数据切换为"),
                    TextSpan(
                      text: " 相同 ",
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    const TextSpan(text: "状态：")
                  ]),
                ),
                const SizedBox(height: 8),
                Expanded(
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 10.0,
                          children: List<Widget>.generate(hosts.length, (index) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: false,
                                  onChanged: (bool? value) {},
                                ),
                                Text(hosts[index].host),
                              ],
                            );
                          }),
                        ),
                      ),
                    )),
              ],
            ),
            actions: [
              TextButton(onPressed: () {}, child: const Text("确认")),
              TextButton(onPressed: () {}, child: const Text("取消")),
            ],
          ));
}

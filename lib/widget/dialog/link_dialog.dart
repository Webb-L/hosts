import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
          title: Text(AppLocalizations.of(context)!.link),
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
                  _buildTitle(host, AppLocalizations.of(context)!.link_contrary,
                      context),
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
                  _buildTitle(
                      host, AppLocalizations.of(context)!.link_same, context),
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
              child: Text(AppLocalizations.of(context)!.ok),
            ),
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context)!.cancel)),
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
      text: AppLocalizations.of(context)!.link_and_description,
      children: [
        TextSpan(
          text: host.host,
          style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary),
        ),
        TextSpan(
            text: AppLocalizations.of(context)!.link_status_update_description),
        TextSpan(
          text: " $text ",
          style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Theme.of(context).colorScheme.primary),
        ),
        TextSpan(text: AppLocalizations.of(context)!.link_status_description),
      ],
      style: Theme.of(context).textTheme.bodyMedium,
    ),
  );
}

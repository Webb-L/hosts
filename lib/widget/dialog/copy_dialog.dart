import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';

class CopyDialog extends StatelessWidget {
  final BuildContext context;
  final List<HostsModel> hosts;
  final int index;

  const CopyDialog(
      {super.key,
      required this.hosts,
      required this.index,
      required this.context});

  @override
  Widget build(BuildContext context) {
    int curIndex = index;
    String outputHostModel = hosts[index].toString();
    return IconButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                  return AlertDialog(
                    title: hosts.length > 1
                        ? Text(
                            "${AppLocalizations.of(context)!.copy}(${curIndex + 1}/${hosts.length})")
                        : Text(AppLocalizations.of(context)!.copy),
                    content: SelectableText(outputHostModel),
                    actions: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              if (hosts.length > 1)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (curIndex - 1 < 0) {
                                        curIndex = hosts.length - 1;
                                      } else {
                                        curIndex--;
                                      }
                                      outputHostModel =
                                          hosts[curIndex].toString();
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_left),
                                ),
                              if (hosts.length > 1)
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      if (curIndex + 1 > hosts.length - 1) {
                                        curIndex = 0;
                                      } else {
                                        curIndex++;
                                      }
                                      outputHostModel =
                                          hosts[curIndex].toString();
                                    });
                                  },
                                  icon: const Icon(Icons.chevron_right),
                                ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              Clipboard.setData(
                                      ClipboardData(text: outputHostModel))
                                  .then((_) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(AppLocalizations.of(context)!
                                        .copy_to_tip),
                                  ),
                                );
                              });
                            },
                            child: Text(AppLocalizations.of(context)!.copy),
                          ),
                        ],
                      ),
                    ],
                  );
                });
              });
        },
        icon: const Icon(Icons.copy));
  }
}

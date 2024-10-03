import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';

class CopyMultipleDialog extends StatelessWidget {
  final List<HostsModel> hosts;

  const CopyMultipleDialog({super.key, required this.hosts});

  @override
  Widget build(BuildContext context) {
    String outputHostModel = hosts.join("\n\n");
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.copy),
      content: SelectableText(outputHostModel),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: outputHostModel)).then((_) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppLocalizations.of(context)!.copy_to_tip),
                ),
              );
            });
          },
          child: Text(AppLocalizations.of(context)!.copy),
        ),
      ],
    );
  }
}

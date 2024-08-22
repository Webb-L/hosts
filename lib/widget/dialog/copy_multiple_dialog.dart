import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosts/model/host_file.dart';

class CopyMultipleDialog extends StatelessWidget {
  final List<HostsModel> hosts;

  const CopyMultipleDialog({super.key, required this.hosts});

  @override
  Widget build(BuildContext context) {
    String outputHostModel = hosts.join("\n\n");
    return AlertDialog(
      title:const Text("复制"),
      content: SelectableText(outputHostModel),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(
                ClipboardData(text: outputHostModel))
                .then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("已复制到剪贴板"),
                ),
              );
            });
          },
          child: const Text("复制"),
        ),
      ],
    );
  }
}

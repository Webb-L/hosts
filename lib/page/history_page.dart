import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/widget/countdown_timer.dart';


class HistoryPage extends StatefulWidget {
  final SimpleHostFileHistory? selectHistory;
  final List<SimpleHostFileHistory> history;

  const HistoryPage({
    super.key,
    required this.selectHistory,
    required this.history,
  });

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  SimpleHostFileHistory? simpleHostFileHistory;
  final List<SimpleHostFileHistory> history = [];
  List<SimpleHostFileHistory> deleteSimpleHostFileHistory = [];

  @override
  void initState() {
    history.clear();
    history.addAll(widget.history);
    if (widget.selectHistory != null) {
      simpleHostFileHistory = widget.selectHistory;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color:Theme.of(context).colorScheme.surfaceContainer,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            decoration: BoxDecoration(
              color:Theme.of(context).colorScheme.surfaceContainer,
            ),
            child: Text(
              AppLocalizations.of(context)!.history,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
                itemCount: history.length,
                itemBuilder: (context, index) {
                  SimpleHostFileHistory hostFile = history[index];
                  DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                      int.parse(hostFile.fileName));

                  String year = dateTime.year.toString();
                  String month = dateTime.month.toString().padLeft(2, '0');
                  String day = dateTime.day.toString().padLeft(2, '0');
                  String hour = dateTime.hour.toString().padLeft(2, '0');
                  String minute = dateTime.minute.toString().padLeft(2, '0');
                  String second = dateTime.second.toString().padLeft(2, '0');

                  return ListTile(
                    title: Text("$year-$month-$day $hour:$minute:$second"),
                    subtitle: deleteSimpleHostFileHistory.contains(hostFile)
                        ? Text(AppLocalizations.of(context)!.history_remove_tip)
                        : null,
                    selected: simpleHostFileHistory == hostFile,
                    leading: deleteSimpleHostFileHistory.contains(hostFile)
                        ? SizedBox(
                            width: 32,
                            height: 32,
                            child: CountdownTimer(
                              onFinish: () {
                                setState(() {
                                  deleteSimpleHostFileHistory.remove(hostFile);
                                  history.remove(hostFile);
                                  FileManager().deleteFile(hostFile.path);
                                });
                              },
                            ))
                        : null,
                    trailing: IconButton(
                        onPressed: () {
                          setState(() {
                            if (deleteSimpleHostFileHistory
                                .contains(hostFile)) {
                              deleteSimpleHostFileHistory.remove(hostFile);
                            } else {
                              deleteSimpleHostFileHistory.add(hostFile);
                            }
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size.zero,
                          padding: EdgeInsets.zero,
                        ),
                        icon: Icon(
                          deleteSimpleHostFileHistory.contains(hostFile)
                              ? Icons.close
                              : Icons.delete_outline,
                        )),
                    selectedTileColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    onTap: () {
                      setState(() {
                        simpleHostFileHistory = hostFile;
                      });
                      Navigator.of(context).pop(simpleHostFileHistory);
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hosts/home/view/hosts_diff_page.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/util/file_manager.dart';
import 'package:hosts/widget/countdown_timer.dart';

class HistoryPage extends StatefulWidget {
  final String fileId;
  final SimpleHostFileHistory? selectHistory;
  final List<SimpleHostFileHistory> history;

  const HistoryPage({
    super.key,
    required this.selectHistory,
    required this.history,
    required this.fileId,
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
      color: Theme.of(context).colorScheme.surfaceContainer,
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
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
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            _showDiffComparison(context, hostFile);
                          },
                          icon: const Icon(Icons.compare_arrows),
                          tooltip: AppLocalizations.of(context)!.view_diff,
                        ),
                        IconButton(
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
                          ),
                          tooltip: AppLocalizations.of(context)!.delete,
                        ),
                      ],
                    ),
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

  void _showDiffComparison(
      BuildContext context, SimpleHostFileHistory hostFile) async {
    try {
      final fileManager = FileManager();

      // 读取历史文件内容
      final historyContent = fileManager.readHistoryFile(hostFile.path);

      // 获取当前文件内容
      final currentContent = await fileManager.readAsString(widget.fileId);

      // 格式化时间标签
      final dateTime =
          DateTime.fromMillisecondsSinceEpoch(int.parse(hostFile.fileName));
      final year = dateTime.year.toString();
      final month = dateTime.month.toString().padLeft(2, '0');
      final day = dateTime.day.toString().padLeft(2, '0');
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final second = dateTime.second.toString().padLeft(2, '0');

      final historyLabel =
          '${AppLocalizations.of(context)!.history_version}: $year-$month-$day $hour:$minute:$second';
      final currentLabel = AppLocalizations.of(context)!.current_version;

      // 导航到差异对比页面
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => HostsDiffPage(
            historyContent: historyContent,
            currentContent: currentContent,
            historyLabel: historyLabel,
            currentLabel: currentLabel,
          ),
        ),
      );
    } catch (e) {
      // 显示错误信息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${AppLocalizations.of(context)!.unable_to_read_history_file}: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

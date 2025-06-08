import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/widget/dialog/copy_dialog.dart';
import 'package:hosts/widget/dialog/link_dialog.dart';
import 'package:hosts/widget/dialog/test_dialog.dart';
import 'package:hosts/widget/snakbar.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

/// 主机表格组件
///
/// 使用SfDataGrid显示主机数据表格，提供：
/// - 排序功能
/// - 分页显示
/// - 交互操作
class HostTable extends StatelessWidget {
  /// 构造函数
  const HostTable({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostCubit, HostState>(
      builder: (context, state) {
        final hostCubit = context.read<HostCubit>();

        return SfDataGrid(
          allowSorting: true,
          columnWidthMode: ColumnWidthMode.fill,
          gridLinesVisibility: GridLinesVisibility.none,
          headerGridLinesVisibility: GridLinesVisibility.none,
          source: HostDataSource(
            hosts: state.data.filterHosts,
            selectHosts: state.data.selectHosts,
            onEdit: (index, host) async {
              List<HostsModel>? hostsModels = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => HostPage(hostModel: host),
                ),
              );
              if (hostsModels == null) return;
              hostCubit.onEdit(index, hostsModels.first);
            },
            onLink: (index, host) async {
              final Map<String, List<String>>? result =
                  await linkDialog(context, state.data.hosts, host);
              if (result == null) return;
              hostCubit.onEdit(index, host.withCopy(config: result));
            },
            onChecked: hostCubit.onChecked,
            onDelete: (hosts) {
              deleteMultiple(context, hosts.map((it) => it.host).toList(),
                  () => hostCubit.onDelete(hosts));
            },
            onToggleUse: hostCubit.onToggleUse,
            onLaunchUrl: (host) {
              print("onLaunchUrl, $host");
            },
            context: context,
          ),
          columns: [
            GridColumn(
              columnName: 'checkbox',
              allowSorting: false,
              label: Checkbox(
                value: state.data.selectHosts.isNotEmpty &&
                    state.data.selectHosts.length == state.data.filterHosts.length,
                onChanged: context.read<HostCubit>().updateCheckedAll,
              ),
              width: 50,
            ),
            GridColumn(
              columnName: 'host',
              allowSorting: true,
              label: Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.ip_address,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            GridColumn(
              columnName: 'use',
              allowSorting: true,
              label: Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.status,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            GridColumn(
              columnName: 'hosts',
              allowSorting: true,
              label: Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.domain,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            GridColumn(
              columnName: 'description',
              allowSorting: true,
              label: Container(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.remark,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
            GridColumn(
              columnName: 'actions',
              allowSorting: false,
              label: Container(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(AppLocalizations.of(context)!.action,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 主机表格数据源
///
/// 负责管理表格数据并提供排序功能
class HostDataSource extends DataGridSource {
  /// 构造函数
  ///
  /// [hosts]: 主机数据列表
  /// [selectHosts]: 已选中的主机列表
  /// [onEdit]: 编辑回调函数
  /// [onLink]: 链接回调函数
  /// [onChecked]: 选中状态变更回调
  /// [onDelete]: 删除回调函数
  /// [onToggleUse]: 使用状态切换回调
  /// [onLaunchUrl]: URL跳转回调
  /// [context]: 构建上下文
  HostDataSource({
    required this.hosts,
    required this.selectHosts,
    required this.onEdit,
    required this.onLink,
    required this.onChecked,
    required this.onDelete,
    required this.onToggleUse,
    required this.onLaunchUrl,
    required this.context,
  });

  final List<HostsModel> hosts;
  final List<HostsModel> selectHosts;
  final Function(int, HostsModel) onEdit;
  final Function(int, HostsModel) onLink;
  final Function(int, HostsModel) onChecked;
  final Function(List<HostsModel>) onDelete;
  final Function(Map<HostsModel, HostsModel>) onToggleUse;
  final Function(String) onLaunchUrl;
  final BuildContext context;

  @override
  List<DataGridRow> get rows => hosts.map((host) {
        bool isLink = false;
        if (host.config.isNotEmpty) {
          isLink =
              host.config["same"] != null && host.config["contrary"] != null;
        }

        return DataGridRow(cells: [
          DataGridCell(
            columnName: 'checkbox',
            value: Checkbox(
              value: selectHosts.contains(host),
              onChanged: (bool? newValue) =>
                  onChecked(hosts.indexOf(host), host),
            ),
          ),
          DataGridCell(
            columnName: 'host',
            value: MyDataGridCell(
                value: host.host,
                child: GestureDetector(
                  onTap: () => onLaunchUrl(host.host),
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (isLink)
                            WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  Icons.link,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          TextSpan(
                            text: host.host,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )),
          ),
          DataGridCell(
            columnName: 'use',
            value: MyDataGridCell(
              value: host.isUse,
              child: Switch(
                value: host.isUse,
                onChanged: (value) {
                  // Map<旧, 新>
                  final Map<HostsModel, HostsModel> updateUseHosts = {
                    host: host.withCopy(isUse: value)
                  };
                  void updateHostStates(List<String> hostNames, bool isUse) {
                    for (var tempHost in hosts
                        .where((item) => hostNames.contains(item.host))) {
                      updateUseHosts[tempHost] =
                          tempHost.withCopy(isUse: isUse);
                    }
                  }

                  if (host.config["same"] != null) {
                    updateHostStates(
                        (host.config["same"] as List<dynamic>).cast<String>(),
                        value);
                  }
                  if (host.config["contrary"] != null) {
                    updateHostStates(
                        (host.config["contrary"] as List<dynamic>)
                            .cast<String>(),
                        !value);
                  }
                  onToggleUse(updateUseHosts);
                },
              ),
            ),
          ),
          DataGridCell(
            columnName: 'hosts',
            value: MyDataGridCell(
              value: host.hosts,
              child: Container(
                alignment: Alignment.centerLeft,
                child: Text.rich(
                  TextSpan(
                    children: _buildTextSpans(host.hosts, context),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          DataGridCell(
            columnName: 'description',
            value: MyDataGridCell(
              value: host.description,
              child: Container(
                  alignment: Alignment.centerLeft,
                  child: SelectableText(host.description)),
            ),
          ),
          DataGridCell(
            columnName: 'actions',
            value: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => onEdit(hosts.indexOf(host), host),
                  icon: const Icon(Icons.edit),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => onDelete([host]),
                  icon: const Icon(Icons.delete_outline),
                ),
                const SizedBox(width: 8),
                buildMoreButton(context, hosts.indexOf(host), host),
              ],
            ),
          ),
        ]);
      }).toList();

  @override
  Future<void> performSorting(List<DataGridRow> rows) async {
    // sortedColumns 是父类提供的属性，里面包含排序列及排序方向等信息。
    if (sortedColumns.isNotEmpty) {
      final sortColumn = sortedColumns.first;
      // SortColumnDetails 通常包含 columnName 和 sortDirection
      final String columnName = sortColumn.name;
      final bool isAscending =
          sortColumn.sortDirection == DataGridSortDirection.ascending;
      if (!["checkbox", "actions"].contains(columnName)) {
        rows.sort((a, b) {
          final valueA = a
              .getCells()
              .firstWhere((cell) => cell.columnName == columnName)
              .value
              .toString();
          final valueB = b
              .getCells()
              .firstWhere((cell) => cell.columnName == columnName)
              .value
              .toString();

          return isAscending
              ? valueA.compareTo(valueB)
              : valueB.compareTo(valueA);
        });
      }
    }
    // notifyListeners();
  }

  List<InlineSpan> _buildTextSpans(List<String> hosts, BuildContext context) {
    List<InlineSpan> textSpans = [];
    for (int i = 0; i < hosts.length; i++) {
      textSpans.add(TextSpan(
        text: hosts[i],
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            onLaunchUrl(hosts[i]);
          },
      ));
      if (i < hosts.length - 1) {
        textSpans.add(TextSpan(
          text: ' - ',
          style: TextStyle(
            color: Theme.of(context).colorScheme.inverseSurface,
            fontWeight: FontWeight.w900,
          ),
        ));
      }
    }
    return textSpans;
  }

  Widget buildMoreButton(BuildContext context, int index, HostsModel host) {
    return PopupMenuButton<int>(
      onSelected: (value) async {
        switch (value) {
          case 1:
            onLink(index, host);
            break;
          case 2:
            testDialog(context, host);
            break;
          case 3:
            copyDialog(context, hosts, index);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        List<Map<String, Object>> list = [
          {
            "icon": Icons.link,
            "text": AppLocalizations.of(context)!.link,
            "value": 1
          },
          {
            "icon": Icons.sensors,
            "text": AppLocalizations.of(context)!.test,
            "value": 2
          },
          {
            "icon": Icons.copy,
            "text": AppLocalizations.of(context)!.copy,
            "value": 3
          },
        ];
        return list
            .where((item) => !(item["value"] == 2 && kIsWeb))
            .map((item) {
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

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells:
          row.getCells().map((dataCell) => dataCell.value as Widget).toList(),
    );
  }
}

class MyDataGridCell extends StatelessWidget {
  final Widget child;
  final dynamic value;

  const MyDataGridCell({super.key, required this.child, required this.value});

  @override
  Widget build(BuildContext context) {
    return child;
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return value.toString();
  }
}

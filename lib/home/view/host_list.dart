import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/widget/dialog/copy_dialog.dart';
import 'package:hosts/widget/dialog/link_dialog.dart';
import 'package:hosts/widget/dialog/test_dialog.dart';
import 'package:hosts/widget/snakbar.dart';

/// 主机列表组件
///
/// 显示主机列表并提供交互功能，包括：
/// - 主机项的增删改查
/// - 状态切换
/// - 排序功能
/// - 批量操作
class HostList extends StatelessWidget {
  /// 构造函数
  const HostList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostCubit, HostState>(
      builder: (BuildContext context, state) {
        final hostCubit = context.read<HostCubit>();
        final hostStateData = state.data;
        return Column(
          children: [
            // 表头行
            Row(
              children: [
                Container(
                  width: 50,
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  child: Checkbox(
                    value: state.data.selectHosts.isNotEmpty &&
                        state.data.selectHosts.length ==
                            state.data.filterHosts.length,
                    onChanged: context.read<HostCubit>().updateCheckedAll,
                  ),
                ),
                HeaderColumn(
                  columnName: 'host',
                  text: AppLocalizations.of(context)!.ip_address,
                  cubit: hostCubit,
                ),
                SizedBox(width: 16),
                HeaderColumn(
                  columnName: 'use',
                  text: AppLocalizations.of(context)!.status,
                  cubit: hostCubit,
                ),
                SizedBox(width: 16),
                HeaderColumn(
                  columnName: 'hosts',
                  text: AppLocalizations.of(context)!.domain,
                  cubit: hostCubit,
                ),
                SizedBox(width: 16),
                HeaderColumn(
                  columnName: 'description',
                  text: AppLocalizations.of(context)!.remark,
                  cubit: hostCubit,
                ),
                SizedBox(width: 16),
                SizedBox(
                  width: 100,
                  child: Text(AppLocalizations.of(context)!.action,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemCount: hostStateData.filterHosts.length,
                itemBuilder: (context, index) {
                  final HostsModel host = hostStateData.filterHosts[index];
                  return InkWell(
                    onTap: () async {
                      List<HostsModel>? hostsModels =
                          await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HostPage(hostModel: host),
                        ),
                      );
                      if (hostsModels == null) return;
                      hostCubit.onEdit(index, hostsModels.first);
                    },
                    child: ListItem(
                      host: host,
                      onSwitchChanged: (value) {
                        // Map<旧, 新>
                        final Map<HostsModel, HostsModel> updateUseHosts = {
                          host: host.withCopy(isUse: value)
                        };
                        void updateHostStates(
                            List<String> hostNames, bool isUse) {
                          for (var tempHost in hostStateData.filterHosts
                              .where((item) => hostNames.contains(item.host))) {
                            updateUseHosts[tempHost] =
                                tempHost.withCopy(isUse: isUse);
                          }
                        }

                        if (host.config["same"] != null) {
                          updateHostStates(
                              (host.config["same"] as List<dynamic>)
                                  .cast<String>(),
                              value);
                        }
                        if (host.config["contrary"] != null) {
                          updateHostStates(
                              (host.config["contrary"] as List<dynamic>)
                                  .cast<String>(),
                              !value);
                        }

                        hostCubit.onToggleUse(updateUseHosts);
                      },
                      onCheckChanged: (value) =>
                          hostCubit.onChecked(index, host),
                      trailing: buildMoreButton(
                          context, hostCubit, hostStateData, index, host),
                      isChecked: hostStateData.selectHosts.contains(host),
                    ),
                  );
                },
              ),
            )
          ],
        );
      },
    );
  }

  Widget buildMoreButton(BuildContext context, HostCubit hostCubit,
      HostStateData hostStateData, int index, HostsModel host) {
    return PopupMenuButton<int>(
      onSelected: (value) async {
        switch (value) {
          case 1:
            final Map<String, List<String>>? result =
                await linkDialog(context, hostStateData.filterHosts, host);
            if (result == null) return;
            hostCubit.onEdit(index, host.withCopy(config: result));
            break;
          case 2:
            testDialog(context, host);
            break;
          case 3:
            copyDialog(context, hostStateData.filterHosts, index);
            break;
          case 4:
            deleteMultiple(
                context,
                hostStateData.filterHosts.map((it) => it.host).toList(),
                () => hostCubit.onDelete([host]));
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
          {
            "icon": Icons.delete_outline,
            "text": AppLocalizations.of(context)!.delete,
            "value": 4
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
}

/// 主机列表项组件
///
/// 显示单个主机项的详细信息，包括：
/// - 复选框状态
/// - 开关状态
/// - 主机信息
/// - 操作按钮
class ListItem extends StatelessWidget {
  /// 是否选中
  final bool isChecked;

  /// 主机数据模型
  final HostsModel host;

  /// 开关状态变更回调
  final ValueChanged<bool> onSwitchChanged;

  /// 复选框状态变更回调
  final ValueChanged<bool?> onCheckChanged;

  /// 右侧操作按钮组件
  final Widget trailing;

  /// 构造函数
  const ListItem(
      {super.key,
      required this.host,
      required this.onSwitchChanged,
      required this.onCheckChanged,
      required this.isChecked,
      required this.trailing});

  @override
  Widget build(BuildContext context) {
    bool isLink = false;
    if (host.config.isNotEmpty) {
      isLink = host.config["same"] != null && host.config["contrary"] != null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 9),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Checkbox(
            value: isChecked,
            onChanged: onCheckChanged,
          ),
          const SizedBox(width: 16),
          Switch(
            value: host.isUse,
            onChanged: onSwitchChanged,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (host.description.isNotEmpty)
                  Text(
                    host.description,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                const SizedBox(height: 4.0),
                Text.rich(TextSpan(
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
                      )),
                    TextSpan(
                      text: host.host,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                )),
                const SizedBox(height: 4.0),
                Text.rich(TextSpan(
                    children: _buildTextSpans(host.hosts, context),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.6),
                        fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const SizedBox(width: 16),
          trailing,
        ],
      ),
    );
  }

  List<InlineSpan> _buildTextSpans(List<String> hosts, BuildContext context) {
    List<InlineSpan> textSpans = [];

    for (int i = 0; i < hosts.length; i++) {
      textSpans.add(TextSpan(
        text: hosts[i],
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            // onLaunchUrl(hosts[i]);
          },
      ));

      if (i < hosts.length - 1) {
        textSpans.add(TextSpan(
            text: ' - ',
            style: TextStyle(
                color: Theme.of(context).colorScheme.inverseSurface,
                fontWeight: FontWeight.w900)));
      }
    }

    return textSpans;
  }
}

class HeaderColumn extends StatelessWidget {
  final String columnName;
  final String text;
  final HostCubit cubit;

  const HeaderColumn({
    super.key,
    required this.columnName,
    required this.text,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () => cubit.onSort(columnName),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                text,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              BlocBuilder<HostCubit, HostState>(
                builder: (context, state) {
                  final direction = state.data.sortStatus[columnName];
                  return Icon(
                    direction == SortDirection.ascending
                        ? Icons.arrow_upward
                        : direction == SortDirection.descending
                            ? Icons.arrow_downward
                            : Icons.unfold_more,
                    size: 16,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

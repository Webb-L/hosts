import 'package:flutter/material.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/widget/dialog/link_dialog.dart';
import 'package:hosts/widget/error/error_empty.dart';
import 'package:hosts/widget/host_list.dart';
import 'package:hosts/widget/host_table.dart';
import 'package:hosts/widget/snakbar.dart';

abstract class BaseHomePage extends StatefulWidget {
  const BaseHomePage({super.key});

  @override
  BaseHomePageState createState();
}

abstract class BaseHomePageState<T extends BaseHomePage> extends State<T> {
  // 选中的主机列表
  final List<HostsModel> selectHosts = [];

  // 过滤后的主机列表
  final List<HostsModel> filterHosts = [];
  HostsFile hostsFile = HostsFile("", "");
  EditMode editMode = EditMode.Table;
  AdvancedSettingsEnum advancedSettingsEnum = AdvancedSettingsEnum.Close;
  String searchText = "";
  Map<String, int?> sortConfig = {
    "host": null,
    "isUse": 1,
    "hosts": null,
    "description": null,
  };
  SimpleHostFileHistory? selectHistory;
  final TextEditingController textEditingController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  /// 处理打开文件的操作
  /// [content] 是文件的内容
  onOpenFile(String content) {
    setState(() {
      hostsFile.formString(content);
      hostsFile.defaultContent = content;
      hostsFile.isUpdateHost();
      updateFilterHosts();
    });
  }

  /// 撤销上一次的主机操作
  undoHost() {
    setState(() {
      hostsFile.undoHost();
      textEditingController.value =
          TextEditingValue(text: hostsFile.toString());
      selectHosts.clear();
      updateFilterHosts();
    });
  }

  /// 处理搜索文本变化
  /// [value] 是新的搜索文本
  onSearchChanged(String value) {
    setState(() {
      searchText = value;
      updateFilterHosts();
    });
  }

  /// 切换高级设置的状态
  /// [value] 是新的高级设置状态
  onSwitchAdvancedSettings(AdvancedSettingsEnum value) {
    setState(() {
      advancedSettingsEnum = value;
    });
  }

  /// 切换编辑模式
  /// [value] 是新的编辑模式
  onSwitchMode(EditMode value) {
    if (editMode == EditMode.Text) {
      editMode = EditMode.Table;
      hostsFile.formString(textEditingController.text);
      selectHosts.clear();
      updateFilterHosts();
    } else {
      editMode = EditMode.Text;
      textEditingController.value =
          TextEditingValue(text: hostsFile.toString());
    }
  }

  /// 处理删除操作
  onDeletePressed() {
    deleteMultiple(
      context,
      selectHosts.map((item) => item.host).toList(),
      () => setState(() {
        hostsFile.deleteMultiple(selectHosts);
        selectHosts.clear();
        updateFilterHosts();
      }),
    );
  }

  /// 处理全选状态变化
  /// [value] 是全选的状态
  onCheckedAllChanged(bool? value) {
    setState(() {
      selectHosts.clear();
      if (value ?? false) {
        selectHosts.addAll(hostsFile.hosts);
      }
    });
  }

  /// 处理排序配置变化
  /// [value] 是新的排序配置
  onSortConfChanged(Map<String, int?> value) {
    setState(() {
      sortConfig = value;
      updateFilterHosts();
    });
  }

  /// 切换主机的使用状态
  /// [value] 是新的使用状态
  onSwitchHosts(bool value) {
    setState(() {
      for (var host in selectHosts) {
        host.isUse = value;
      }
      updateFilterHosts();
    });
  }

  /// 更新过滤后的主机列表
  updateFilterHosts() {
    filterHosts.clear();
    filterHosts.addAll(hostsFile.filterHosts(searchText, sortConfig));
  }

  /// 处理单个主机的选中状态
  /// [index] 是主机的索引
  /// [host] 是被选中的主机
  onChecked(int index, HostsModel host) {
    setState(() {
      if (selectHosts.contains(host)) {
        selectHosts.remove(host);
      } else {
        selectHosts.add(host);
      }
    });
  }

  /// 处理主机链接的操作
  /// [index] 是主机的索引
  /// [host] 是被链接的主机
  onLink(int index, HostsModel host) async {
    final Map<String, List<String>>? result =
        await linkDialog(context, hostsFile.hosts, host);
    if (result == null) return;
    setState(() {
      host.config = result;
      hostsFile.updateHost(index, host);
    });
  }

  /// 处理主机编辑操作
  /// [index] 是主机的索引
  /// [host] 是被编辑的主机
  onEdit(int index, HostsModel host) async {
    List<HostsModel>? hostsModels = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HostPage(hostModel: host),
      ),
    );
    if (hostsModels == null) return;
    setState(() {
      hostsFile.updateHost(index, hostsModels.first);
      selectHosts.clear();
      filterHosts.clear();
      filterHosts.addAll(hostsFile.filterHosts(searchText, sortConfig));
    });
  }

  /// 处理主机删除操作
  /// [hosts] 是要删除的主机列表
  onDelete(List<HostsModel> hosts) {
    deleteMultiple(
      context,
      hosts.map((item) => item.host).toList(),
      () => setState(() {
        hostsFile.deleteMultiple(hosts);
      }),
    );
  }

  /// 切换主机的使用状态
  /// [hosts] 是要切换状态的主机列表
  onToggleUse(List<HostsModel> hosts) {
    setState(() {
      hostsFile.updateHostUseState(hosts);
      selectHosts.clear();
      filterHosts.clear();
      filterHosts.addAll(hostsFile.filterHosts(searchText, sortConfig));
    });
  }

  /// 构建浮动操作按钮
  /// [context] 是构建按钮的上下文
  FloatingActionButton? buildFloatingActionButton(BuildContext context) {
    if (editMode == EditMode.Table) {
      return FloatingActionButton(
        onPressed: () async {
          List<HostsModel>? hostsModels = await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => const HostPage()));
          if (hostsModels == null) return;
          setState(() {
            for (HostsModel hostsModel in hostsModels) {
              hostsFile.addHost(hostsModel);
            }
            selectHosts.clear();
          });
        },
        child: const Icon(Icons.add),
      );
    }
    return null;
  }

  /// 构建主机表格或文本编辑器
  /// [filterHosts] 是过滤后的主机列表
  Widget buildHostTableOrTextEdit(List<HostsModel> filterHosts) {
    if (editMode == EditMode.Text) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: TextField(
            controller: textEditingController,
            maxLines: double.maxFinite.toInt(),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      );
    }

    if (filterHosts.isEmpty) {
      return Expanded(
        child: Container(
          alignment: Alignment.center,
          width: double.maxFinite,
          height: double.maxFinite,
          child: const ErrorEmpty(),
        ),
      );
    }

    if (MediaQuery.of(context).size.width >= 1280) {
      return Expanded(
        child: HostTable(
          hosts: filterHosts,
          selectHosts: selectHosts,
          onChecked: onChecked,
          onLink: onLink,
          onEdit: onEdit,
          onDelete: onDelete,
          onToggleUse: onToggleUse,
          onLaunchUrl: (url) {
            // Uncomment and implement the URL launching logic if needed
            // if (!await launchUrl(Uri.https(url))) {
            //   throw Exception('Could not launch $url');
            // }
          },
        ),
      );
    } else {
      return Expanded(
        child: HostList(
          hosts: filterHosts,
          selectHosts: selectHosts,
          onChecked: onChecked,
          onLink: onLink,
          onEdit: onEdit,
          onDelete: onDelete,
          onToggleUse: onToggleUse,
          onLaunchUrl: (url) {
            // Uncomment and implement the URL launching logic if needed
            // if (!await launchUrl(Uri.https(url))) {
            //   throw Exception('Could not launch $url');
            // }
          },
        ),
      );
    }
  }
}

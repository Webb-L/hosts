import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/model/host_file.dart';
import 'package:hosts/model/simple_host_file.dart';
import 'package:hosts/page/host_page.dart';
import 'package:hosts/widget/dialog/link_dialog.dart';
import 'package:hosts/widget/error/error_empty.dart';
import 'package:hosts/widget/host_list.dart';
import 'package:hosts/widget/host_table.dart';
import 'package:hosts/widget/host_text_editing_controller.dart';
import 'package:hosts/widget/row_line_widget.dart';
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
    "isUse": null,
    "hosts": null,
    "description": null,
  };
  SimpleHostFileHistory? selectHistory;
  final HostTextEditingController textEditingController =
      HostTextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isControl = false;

  final ScrollController _scrollController = ScrollController();
  final ScrollController _textScrollController = ScrollController();

  final GlobalKey _textFieldContainerKey = GlobalKey();

  @override
  void initState() {
    _textScrollController.addListener(() {
      if (_textScrollController.hasClients) {
        _scrollController.jumpTo(_textScrollController.offset);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    textEditingController.dispose();
  }

  /// 处理打开文件的操作
  /// [content] 是文件的内容
  onOpenFile(String content) {
    setState(() {
      hostsFile.formString(content);
      hostsFile.defaultContent = content;
      hostsFile.isUpdateHost();
      syncFilterHosts();
    });
  }

  /// 撤销上一次的主机操作
  undoHost() {
    setState(() {
      hostsFile.undoHost();
      textEditingController.value =
          TextEditingValue(text: hostsFile.toString());
      syncFilterHosts();
    });
  }

  /// 处理搜索文本变化
  /// [value] 是新的搜索文本
  onSearchChanged(String value) {
    setState(() {
      searchText = value;
      syncFilterHosts();
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
    setState(() {
      if (editMode == EditMode.Text) {
        editMode = EditMode.Table;
        hostsFile.formString(textEditingController.text);
        syncFilterHosts();
      } else {
        editMode = EditMode.Text;
        textEditingController.value =
            TextEditingValue(text: hostsFile.toString());
      }
    });
  }

  /// 处理删除操作
  onDeletePressed() {
    deleteMultiple(
      context,
      selectHosts.map((item) => item.host).toList(),
      () => setState(() {
        hostsFile.deleteMultiple(selectHosts);
        syncFilterHosts();
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
      syncFilterHosts();
    });
  }

  /// 切换主机的使用状态
  /// [value] 是新的使用状态
  onSwitchHosts(bool value) {
    setState(() {
      for (var host in selectHosts) {
        host.isUse = value;
      }
      // syncFilterHosts();
    });
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
      syncFilterHosts();
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
        syncFilterHosts();
      }),
    );
  }

  /// 切换主机的使用状态
  /// [hosts] 是要切换状态的主机列表
  onToggleUse(List<HostsModel> hosts) {
    setState(() {
      hostsFile.updateHostUseState(hosts);
      syncFilterHosts();
    });
  }

  /// 同步变更的 Hosts 文件
  void syncFilterHosts() {
    selectHosts.clear();
    filterHosts.clear();
    filterHosts.addAll(hostsFile.filterHosts(searchText, sortConfig));
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
            syncFilterHosts();
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
        child: Column(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RowLineWidget(
                    textEditingController: textEditingController,
                    context: context,
                    textFieldContainerKey: _textFieldContainerKey,
                    scrollController: _scrollController,
                  ),
                  Expanded(
                    key: _textFieldContainerKey,
                    child: KeyboardListener(
                      focusNode: _focusNode,
                      onKeyEvent: (event) {
                        if ([
                          LogicalKeyboardKey.controlLeft,
                          LogicalKeyboardKey.controlRight
                        ].contains(event.logicalKey)) {
                          if (isControl) {
                            isControl = false;
                          } else {
                            isControl = true;
                          }
                        }
                        if (event.logicalKey == LogicalKeyboardKey.slash &&
                            isControl &&
                            event is KeyDownEvent) {
                          textEditingController
                              .updateUseStatus(textEditingController.selection);
                        }

                        if (event.logicalKey == LogicalKeyboardKey.keyS &&
                            isControl &&
                            event is KeyDownEvent) {
                          print("保存");
                        }
                      },
                      child: TextField(
                        controller: textEditingController,
                        scrollController: _textScrollController,
                        maxLines: double.maxFinite.toInt(),
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  Text(
                    "当前行：${textEditingController.countNewlines(textEditingController.text.substring(0, textEditingController.selection.start > 0 ? textEditingController.selection.start : 0)) + 1}",
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                      "总行数：${textEditingController.countNewlines(textEditingController.text) + 1}"),
                ],
              ),
            )
          ],
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

    if (MediaQuery.of(context).size.width >= 1000) {
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

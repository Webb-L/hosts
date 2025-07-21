import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/widget/host_text_editing_controller.dart';
import 'package:hosts/widget/row_line_widget.dart';

/// 主机文本编辑组件
///
/// 提供主机文件的文本编辑功能，包括：
/// - 行号显示
/// - 快捷键操作
/// - 文本内容同步
class HostText extends StatefulWidget {
  /// 构造函数
  const HostText({super.key});

  @override
  State<HostText> createState() => _HostTextState();
}

/// HostText组件的状态类
///
/// 管理文本编辑器的状态和交互逻辑，包括：
/// - 文本控制器初始化
/// - 快捷键处理
/// - 滚动同步
class _HostTextState extends State<HostText> {
  HostTextEditingController textEditingController = HostTextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool isControl = false;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _textScrollController = ScrollController();
  final GlobalKey _textFieldContainerKey = GlobalKey();
  bool _isScrollingSynchronized = false;

  @override
  void initState() {
    final hostCubit = context.read<HostCubit>();
    textEditingController
      ..text = hostCubit.state.data.fileContent
      ..addListener(() {
        hostCubit.updateFileContent(textEditingController.text);
      });
    
    // Synchronize scroll controllers
    _textScrollController.addListener(() {
      if (!_isScrollingSynchronized && _scrollController.hasClients) {
        _isScrollingSynchronized = true;
        _scrollController.jumpTo(_textScrollController.offset);
        _isScrollingSynchronized = false;
      }
    });
    
    _scrollController.addListener(() {
      if (!_isScrollingSynchronized && _textScrollController.hasClients) {
        _isScrollingSynchronized = true;
        _textScrollController.jumpTo(_scrollController.offset);
        _isScrollingSynchronized = false;
      }
    });
    
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    _scrollController.dispose();
    _textScrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostCubit, HostState>(
      builder: (BuildContext context, state) {
        if (state is HostUndo || state is HostInitial || state is HostHistory) {
          textEditingController.text = state.data.fileContent;
        }
        final hostCubit = context.read<HostCubit>();
        return Column(
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
                        List<LogicalKeyboardKey> logicalKeys = [];
                        if (Platform.isMacOS) {
                          logicalKeys = [
                            LogicalKeyboardKey.metaLeft,
                            LogicalKeyboardKey.metaRight
                          ];
                        } else {
                          logicalKeys = [
                            LogicalKeyboardKey.controlLeft,
                            LogicalKeyboardKey.controlRight
                          ];
                        }
                        if (logicalKeys.contains(event.logicalKey)) {
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
                            event is KeyDownEvent &&
                            !state.data.isSave) {
                          hostCubit.onTextSave();
                        }
                      },
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: IntrinsicWidth(
                            child: TextField(
                              controller: textEditingController,
                              scrollController: _textScrollController,
                              maxLines: null,
                              scrollPhysics: const ClampingScrollPhysics(),
                              decoration:
                                  const InputDecoration(border: InputBorder.none),
                            ),
                          ),
                        ),
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
        );
      },
    );
  }
}

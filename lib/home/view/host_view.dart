import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/enums.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/home/view/host_list.dart';
import 'package:hosts/home/view/host_table.dart';
import 'package:hosts/home/view/host_text.dart';
import 'package:hosts/widget/error/error_empty.dart';

/// 主机视图组件
///
/// 根据编辑模式和屏幕尺寸显示不同的主机视图：
/// - 文本编辑模式显示HostText
/// - 表格模式显示HostTable
/// - 列表模式显示HostList
class HostView extends StatelessWidget {
  /// 主页状态数据
  final HomeStateData data;

  /// 构造函数
  ///
  /// [data]: 主页状态数据
  /// [key]: 组件key
  const HostView(this.data, {super.key});

  /// 构建组件布局
  ///
  /// [context]: 构建上下文
  /// 返回: 根据编辑模式和屏幕尺寸返回对应的视图组件
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostCubit, HostState>(
        builder: (BuildContext context, state) {
      if (data.editMode == EditMode.Text) {
        return Expanded(
          child: HostText(),
        );
      }

      if (state.data.filterHosts.isEmpty) {
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
        return Expanded(child: HostTable());
      }

      return Expanded(child: HostList());
    });
  }
}

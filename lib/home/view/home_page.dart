import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hosts/home/cubit/home_cubit.dart';
import 'package:hosts/home/cubit/host_cubit.dart';
import 'package:hosts/home/view/home_view.dart';

/// 首页页面组件
///
/// 负责初始化和管理首页相关的Cubit状态
/// 包含HomeCubit和HostCubit的初始化
class HomePage extends StatelessWidget {
  /// 构造函数
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<HomeCubit>(create: (context) => HomeCubit()),
        BlocProvider<HostCubit>(create: (context) => HostCubit()),
      ],
      child: const HomeView(),
    );
  }
}

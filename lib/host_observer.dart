import 'package:bloc/bloc.dart';

/// 主机观察者类
/// 用于观察应用中所有BLoC状态变化的观察者
class HostObserver extends BlocObserver {
  /// 构造函数
  const HostObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    // 打印状态变化日志（忽略避免打印的警告）
    // ignore: avoid_print
    print('${bloc.runtimeType} $change');
  }
}

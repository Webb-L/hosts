part of 'home_cubit.dart';

/// 首页状态数据类
/// 保存所有与首页相关的状态属性
/// 首页状态数据模型
class HomeStateData {
  /// 所有host文件列表
  final List<SimpleHostFile> hostFiles;
  
  /// 当前使用的host文件列表
  final List<String> useHostFiles;
  
  /// 当前选中的host文件
  final String selectHostFile;
  
  /// 编辑模式(表格/文本)
  final EditMode editMode;
  
  /// 高级设置状态
  final AdvancedSettingsEnum advancedSettingsEnum;

  /// 搜索文本
  final String searchText;

  /// 构造函数
  const HomeStateData(
      {this.hostFiles = const [],
      this.useHostFiles = const [],
      this.selectHostFile = "",
      this.editMode = EditMode.Table,
      this.advancedSettingsEnum = AdvancedSettingsEnum.Close,
      this.searchText = ""});

  /// 复制方法
  /// 用于基于当前状态创建新状态
  HomeStateData copyWith({
    List<SimpleHostFile>? hostFiles,
    List<String>? useHostFiles,
    String? selectHostFile,
    EditMode? editMode,
    AdvancedSettingsEnum? advancedSettingsEnum,
    String? searchText,
  }) {
    return HomeStateData(
      hostFiles: hostFiles ?? this.hostFiles,
      useHostFiles: useHostFiles ?? this.useHostFiles,
      selectHostFile: selectHostFile ?? this.selectHostFile,
      editMode: editMode ?? this.editMode,
      advancedSettingsEnum: advancedSettingsEnum ?? this.advancedSettingsEnum,
      searchText: searchText ?? this.searchText,
    );
  }
}

/// 首页状态基类
/// 使用密封类设计模式限制状态类型
/// 不可变状态基类
@immutable
sealed class HomeState {
  final HomeStateData data;

  const HomeState(this.data);
}

/// 初始状态
class HomeInitial extends HomeState {
  const HomeInitial(super.data);
}

/// 编辑模式变更状态
/// 当用户切换编辑模式(表格/文本)时触发
class HomeEditMode extends HomeState {
  const HomeEditMode(super.data);
}

/// 数据加载完成状态 
class HomeLoaded extends HomeState {
  const HomeLoaded(super.data);
}

/// 数据加载中状态
class HomeLoading extends HomeState {
  const HomeLoading(super.data);
}

/// 错误状态
/// 包含错误信息
class HomeError extends HomeState {
  final String message;
  const HomeError(super.data, this.message);
}

/// 选择的host文件变更状态
class HomeSelectHostFileChanged extends HomeState {
  const HomeSelectHostFileChanged(super.data);
}

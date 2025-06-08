part of 'host_cubit.dart';

/// 包含主机文件状态的所有数据
class HostStateData {
  /// 当前文件的唯一标识符
  final String fileId;
  
  /// 文件内容文本
  final String fileContent;
  
  /// 默认文件内容文本
  final String defaultFileContent;
  
  /// 标识文件是否已保存
  final bool isSave;
  
  /// 过滤后的主机列表
  final List<HostsModel> filterHosts;
  
  /// 当前显示的主机列表
  final List<HostsModel> hosts;
  
  /// 默认主机列表
  final List<HostsModel> defaultHosts;
  
  /// 用户选择的主机列表
  final List<HostsModel> selectHosts;
  
  /// 当前选择的历史记录
  final SimpleHostFileHistory? selectHistory;
  
  /// 所有历史记录列表
  final List<SimpleHostFileHistory> history;

  /// 搜索文本
  final String searchText;

  /// 各列排序状态
  final Map<String, SortDirection?> sortStatus;

  /// 创建 HostStateData 实例
  /// 
  /// [fileId]: 文件ID，默认为空字符串
  /// [fileContent]: 文件内容，默认为空字符串
  /// [isSave]: 是否已保存，默认为true
  /// [filterHosts]: 过滤后的主机列表，默认为空列表
  /// [hosts]: 主机列表，默认为空列表
  /// [defaultHosts]: 默认主机列表，默认为空列表
  /// [selectHosts]: 选中的主机列表，默认为空列表
  /// [selectHistory]: 选中的历史记录，默认为null
  /// [history]: 历史记录列表，默认为空列表
  /// [searchText]: 搜索文本，默认为空字符串
  HostStateData({
    this.fileId = "",
    this.fileContent = "",
    this.defaultFileContent = "",
    this.isSave = true,
    this.filterHosts = const [],
    this.hosts = const [],
    this.defaultHosts = const [],
    this.selectHosts = const [],
    this.selectHistory,
    this.history = const [],
    this.searchText = "",
    this.sortStatus = const {},
  });

  /// 创建当前状态的副本，可选择更新部分字段
  /// 
  /// 返回一个新的 HostStateData 实例，其中未提供的参数将保留原值
  HostStateData copyWith({
    String? fileId,
    String? fileContent,
    String? defaultFileContent,
    bool? isSave,
    List<HostsModel>? filterHosts,
    List<HostsModel>? hosts,
    List<HostsModel>? defaultHosts,
    List<HostsModel>? selectHosts,
    SimpleHostFileHistory? selectHistory,
    List<SimpleHostFileHistory>? history,
    String? searchText,
    Map<String, SortDirection?>? sortStatus,
  }) {
    return HostStateData(
      fileId: fileId ?? this.fileId,
      fileContent: fileContent ?? this.fileContent,
      defaultFileContent: defaultFileContent ?? this.defaultFileContent,
      isSave: isSave ?? this.isSave,
      filterHosts: filterHosts ?? this.filterHosts,
      hosts: hosts ?? this.hosts,
      defaultHosts: defaultHosts ?? this.defaultHosts,
      selectHosts: selectHosts ?? this.selectHosts,
      selectHistory: selectHistory ?? this.selectHistory,
      history: history ?? this.history,
      searchText: searchText ?? this.searchText,
      sortStatus: sortStatus ?? this.sortStatus,
    );
  }
}

/// 主机状态的基类，所有具体状态都必须继承此类
/// 
/// 使用 sealed 修饰确保所有子类都在同一文件中定义
@immutable
sealed class HostState {
  /// 当前状态关联的数据
  final HostStateData data;

  /// 创建 HostState 实例
  const HostState(this.data);
}

/// 初始状态，表示应用刚启动时的状态
final class HostInitial extends HostState {
  /// 创建初始状态
  const HostInitial(super.data);
}

/// 切换主机使用状态时的状态
final class HostToggleUse extends HostState {
  /// 创建切换使用状态
  const HostToggleUse(super.data);
}

/// 编辑主机时的状态
final class HostEdit extends HostState {
  /// 创建编辑状态
  const HostEdit(super.data);
}

/// 过滤主机时的状态
final class HostFilter extends HostState {
  /// 创建过滤状态
  const HostFilter(super.data);
}

/// 主机被选中时的状态
final class HostChecked extends HostState {
  /// 创建选中状态
  const HostChecked(super.data);
}

/// 删除主机时的状态
final class HostDelete extends HostState {
  /// 创建删除状态
  const HostDelete(super.data);
}

/// 添加主机时的状态
final class HostAdd extends HostState {
  /// 创建添加状态
  const HostAdd(super.data);
}

/// 撤销操作时的状态
final class HostUndo extends HostState {
  /// 创建撤销状态
  const HostUndo(super.data);
}

/// 历史记录变更时的状态
final class HostHistory extends HostState {
  /// 创建历史记录状态
  const HostHistory(super.data);
}

/// 文件内容变更时的状态
final class HostFileContent extends HostState {
  /// 创建文件内容状态
  const HostFileContent(super.data);
}

/// 保存操作完成时的状态
/// 
/// 当主机文件保存成功后触发此状态
final class HostSave extends HostState {
  /// 创建保存状态
  const HostSave(super.data);
}

final class HostSort extends HostState {
  const HostSort(super.data);
}

final class HostEditMode extends HostState {
  const HostEditMode(super.data);
}

/// 主机数据加载完成时的状态
final class HostLoaded extends HostState {
  /// 创建加载完成状态
  const HostLoaded(super.data);
}

/// 正在加载主机数据时的状态
final class HostLoading extends HostState {
  /// 创建加载中状态
  const HostLoading(super.data);
}

/// 发生错误时的状态
final class HostError extends HostState {
  /// 错误信息
  final String message;

  /// 创建错误状态
  const HostError(super.data, this.message);
}

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get app_name => 'Hosts 编辑器';

  @override
  String get ok => '确认';

  @override
  String get cancel => '取消';

  @override
  String get add => '新增';

  @override
  String get create => '创建';

  @override
  String get edit => '编辑';

  @override
  String get remove => '删除';

  @override
  String get abort => '舍弃';

  @override
  String get remark => '备注';

  @override
  String get info => '信息';

  @override
  String get input_remark => '请输入备注';

  @override
  String remove_single_tip(Object name) {
    return '您确认需要删除《$name》吗？';
  }

  @override
  String remove_multiple_tip(Object count) {
    return '确认删除选中的$count条记录吗？';
  }

  @override
  String get save => '保存';

  @override
  String get save_create_history => '保存并生成历史';

  @override
  String get default_hosts_text => '默认';

  @override
  String get input_search => '搜索...';

  @override
  String get use => '使用';

  @override
  String get prev => '上一个';

  @override
  String get next => '下一个';

  @override
  String get ip_address => 'IP地址';

  @override
  String get input_ip_address => '请输入IP地址';

  @override
  String get input_ip_address_hint => '支持IPV4和IPV6';

  @override
  String get input_ipv4_ipv6 => '请输入IPV4或IPV6地址';

  @override
  String get create_host_template =>
      '模板1 - 未启用：\n# 127.0.0.1 flutter.dev\n\n模板2 - 没备注：\n127.0.0.1 flutter.dev\n\n模板3 - 有备注：\n# Flutter\n127.0.0.1 flutter.dev\n\n...';

  @override
  String get history => '历史';

  @override
  String get domain => '域名';

  @override
  String get input_domain => '请输入域名';

  @override
  String get error_domain_tip => '请不要输入空格(“ ”)和换行(“\n”)。';

  @override
  String get error_exist_domain_tip => '该域名已存在';

  @override
  String get history_remove_tip => '历史记录将在5秒后被移除。点击右侧按钮以取消。';

  @override
  String get error_null_data => '找不到数据';

  @override
  String get error_use_fail => '使用失败';

  @override
  String get error_not_save => '当前文件包含未保存的更改';

  @override
  String get error_save_fail => '保存失败';

  @override
  String get table => '表格';

  @override
  String get text => '文本';

  @override
  String get copy => '复制';

  @override
  String get status => '状态';

  @override
  String get action => '操作';

  @override
  String get copy_selected => '复制选中';

  @override
  String get delete_selected => '删除选中';

  @override
  String get reduction => '还原';

  @override
  String get advanced_settings => '高级设置';

  @override
  String get copy_to_tip => '已复制到剪贴板';

  @override
  String get warning => '警告';

  @override
  String get warning_different =>
      '系统 Hosts 文件与当前文件不一致！\n如果您不做覆盖处理，修改后保存当前文件会导致系统文件的数据被覆盖。';

  @override
  String get warning_different_covering_system => '当前覆盖系统';

  @override
  String get warning_different_covering_current => '系统覆盖当前';

  @override
  String get error_not_update_save_tip => '内容已更新！请确保保存您的更改，以免丢失重要信息。';

  @override
  String get error_not_update_save_permission_tip => '该文件已被使用保存时需要管理员权限。';

  @override
  String get test => '测试';

  @override
  String get error_test_ip_notfound => '未找到 IP 地址';

  @override
  String get error_test_ip_different => '找到 IP 地址和设置 IP 地址并不一致';

  @override
  String get link => '关联';

  @override
  String get delete => '删除';

  @override
  String get open_file => '打开文件';

  @override
  String get export => '导出';

  @override
  String get export_data => '导出 Hosts 数据';

  @override
  String get export_success => '文件导出成功';

  @override
  String get error_open_file => '文件读取失败';

  @override
  String get error_open_file_size => '读取文件不能大于10MB';

  @override
  String get about => '关于';

  @override
  String get about_description =>
      'Hosts Editor 是一个使用 Flutter 开发的应用程序，旨在简化 Linux、MacOS、Windows 系统上 hosts 文件的编辑和管理。\n该工具提供了一个用户友好的界面，使用户能够轻松地添加、修改和删除 hosts 文件中的条目。';

  @override
  String get link_contrary => '相反';

  @override
  String get link_same => '相同';

  @override
  String get link_and_description => '当 ';

  @override
  String get link_status_update_description => ' 状态变化时，下列数据切换为';

  @override
  String get link_status_description => '状态：';

  @override
  String get form => '表单';

  @override
  String get import_data => '导入 Hosts 数据';

  @override
  String get import_success => '导入成功';

  @override
  String get loading => '加载中';

  @override
  String get file_processing => '文件处理中';

  @override
  String get import_file => '导入文件';

  @override
  String get will_overwrite => '将覆盖现有文件';

  @override
  String get remote_sync => '远程同步';

  @override
  String get import => '导入';

  @override
  String get server_settings => '服务器设置';

  @override
  String get server_status => '服务器状态';

  @override
  String get server_config => '服务器配置';

  @override
  String get server_running => '运行中';

  @override
  String get server_stopped => '已停止';

  @override
  String get server_start => '启动';

  @override
  String get server_stop => '停止';

  @override
  String get server_restart => '重启';

  @override
  String get server_host => '主机地址';

  @override
  String get server_port => '端口';

  @override
  String get server_auto_start => '自动启动';

  @override
  String get server_auto_start_desc => '应用启动时自动启动HTTP服务器';

  @override
  String get server_save_config => '保存配置';

  @override
  String get server_copy_url => '复制URL';

  @override
  String get server_url_copied => 'URL已复制到剪贴板';

  @override
  String get server_started => '服务器已启动';

  @override
  String get server_stopped_msg => '服务器已停止';

  @override
  String get server_config_saved => '配置保存成功';

  @override
  String get server_operation_failed => '操作失败';

  @override
  String get server_invalid_port => '端口号必须在1-65535之间';

  @override
  String get server_invalid_host => '主机地址不能为空';

  @override
  String get api_docs => 'API文档';

  @override
  String get api_endpoints => '可用的API端点';

  @override
  String get refresh_status => '刷新状态';

  @override
  String get server_address => '服务器地址';

  @override
  String get copy_url => '复制URL';

  @override
  String get operation_failed => '操作失败';

  @override
  String get load_server_settings_failed => '加载服务器设置失败';

  @override
  String get get_all_hosts_files => '获取所有hosts文件';

  @override
  String get get_specific_hosts_file => '获取特定hosts文件内容（纯文本）';

  @override
  String get get_hosts_file_history => '获取hosts文件历史记录';

  @override
  String get get_specific_history_content => '获取特定历史记录内容（纯文本）';

  @override
  String get server_already_running => '服务器已经在运行中';

  @override
  String get http_server_start_success => 'HTTP服务器启动成功';

  @override
  String get http_server_start_failed => '启动HTTP服务器失败';

  @override
  String get http_server_stopped => 'HTTP服务器已停止';

  @override
  String get missing_file_id => '缺少文件ID';

  @override
  String get read_file_failed => '读取文件失败';

  @override
  String get missing_file_id_or_history_id => '缺少文件ID或历史记录ID';

  @override
  String get history_not_found => '历史记录不存在';

  @override
  String get read_history_failed => '读取历史记录失败';

  @override
  String get select_hosts_to_export => '请选择要导出hosts文件';

  @override
  String get select_all => '全选';

  @override
  String get selected_count => '已选择';

  @override
  String get export_failed => '导出失败';

  @override
  String get nearby_devices => '附近设备';

  @override
  String get scan_nearby_devices => '扫描附近设备';

  @override
  String get no_nearby_devices => '没有发现开启共享功能的设备\n点击刷新按钮扫描附近设备';

  @override
  String get scanning_devices => '正在扫描附近设备...';

  @override
  String get sharing_enabled => '共享服务已开启';

  @override
  String get device_reachable => '设备可达';

  @override
  String get visit_device => '访问设备';

  @override
  String get access_denied_file_not_allowed => '访问被拒绝：文件不被允许';

  @override
  String get select_hosts_to_share => '请选择要分享的hosts文件';
}

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
}

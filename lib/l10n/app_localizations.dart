import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @app_name.
  ///
  /// In zh, this message translates to:
  /// **'Hosts 编辑器'**
  String get app_name;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'新增'**
  String get add;

  /// No description provided for @create.
  ///
  /// In zh, this message translates to:
  /// **'创建'**
  String get create;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get remove;

  /// No description provided for @abort.
  ///
  /// In zh, this message translates to:
  /// **'舍弃'**
  String get abort;

  /// No description provided for @remark.
  ///
  /// In zh, this message translates to:
  /// **'备注'**
  String get remark;

  /// No description provided for @info.
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get info;

  /// No description provided for @input_remark.
  ///
  /// In zh, this message translates to:
  /// **'请输入备注'**
  String get input_remark;

  /// No description provided for @remove_single_tip.
  ///
  /// In zh, this message translates to:
  /// **'您确认需要删除《{name}》吗？'**
  String remove_single_tip(Object name);

  /// No description provided for @remove_multiple_tip.
  ///
  /// In zh, this message translates to:
  /// **'确认删除选中的{count}条记录吗？'**
  String remove_multiple_tip(Object count);

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @save_create_history.
  ///
  /// In zh, this message translates to:
  /// **'保存并生成历史'**
  String get save_create_history;

  /// No description provided for @default_hosts_text.
  ///
  /// In zh, this message translates to:
  /// **'默认'**
  String get default_hosts_text;

  /// No description provided for @input_search.
  ///
  /// In zh, this message translates to:
  /// **'搜索...'**
  String get input_search;

  /// No description provided for @use.
  ///
  /// In zh, this message translates to:
  /// **'使用'**
  String get use;

  /// No description provided for @prev.
  ///
  /// In zh, this message translates to:
  /// **'上一个'**
  String get prev;

  /// No description provided for @next.
  ///
  /// In zh, this message translates to:
  /// **'下一个'**
  String get next;

  /// No description provided for @ip_address.
  ///
  /// In zh, this message translates to:
  /// **'IP地址'**
  String get ip_address;

  /// No description provided for @input_ip_address.
  ///
  /// In zh, this message translates to:
  /// **'请输入IP地址'**
  String get input_ip_address;

  /// No description provided for @input_ip_address_hint.
  ///
  /// In zh, this message translates to:
  /// **'支持IPV4和IPV6'**
  String get input_ip_address_hint;

  /// No description provided for @input_ipv4_ipv6.
  ///
  /// In zh, this message translates to:
  /// **'请输入IPV4或IPV6地址'**
  String get input_ipv4_ipv6;

  /// No description provided for @create_host_template.
  ///
  /// In zh, this message translates to:
  /// **'模板1 - 未启用：\n# 127.0.0.1 flutter.dev\n\n模板2 - 没备注：\n127.0.0.1 flutter.dev\n\n模板3 - 有备注：\n# Flutter\n127.0.0.1 flutter.dev\n\n...'**
  String get create_host_template;

  /// No description provided for @history.
  ///
  /// In zh, this message translates to:
  /// **'历史'**
  String get history;

  /// No description provided for @domain.
  ///
  /// In zh, this message translates to:
  /// **'域名'**
  String get domain;

  /// No description provided for @input_domain.
  ///
  /// In zh, this message translates to:
  /// **'请输入域名'**
  String get input_domain;

  /// No description provided for @error_domain_tip.
  ///
  /// In zh, this message translates to:
  /// **'请不要输入空格(“ ”)和换行(“\n”)。'**
  String get error_domain_tip;

  /// No description provided for @error_exist_domain_tip.
  ///
  /// In zh, this message translates to:
  /// **'该域名已存在'**
  String get error_exist_domain_tip;

  /// No description provided for @history_remove_tip.
  ///
  /// In zh, this message translates to:
  /// **'历史记录将在5秒后被移除。点击右侧按钮以取消。'**
  String get history_remove_tip;

  /// No description provided for @error_null_data.
  ///
  /// In zh, this message translates to:
  /// **'找不到数据'**
  String get error_null_data;

  /// No description provided for @error_use_fail.
  ///
  /// In zh, this message translates to:
  /// **'使用失败'**
  String get error_use_fail;

  /// No description provided for @error_not_save.
  ///
  /// In zh, this message translates to:
  /// **'当前文件包含未保存的更改'**
  String get error_not_save;

  /// No description provided for @error_save_fail.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get error_save_fail;

  /// No description provided for @table.
  ///
  /// In zh, this message translates to:
  /// **'表格'**
  String get table;

  /// No description provided for @text.
  ///
  /// In zh, this message translates to:
  /// **'文本'**
  String get text;

  /// No description provided for @copy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get copy;

  /// No description provided for @status.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get status;

  /// No description provided for @action.
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get action;

  /// No description provided for @copy_selected.
  ///
  /// In zh, this message translates to:
  /// **'复制选中'**
  String get copy_selected;

  /// No description provided for @delete_selected.
  ///
  /// In zh, this message translates to:
  /// **'删除选中'**
  String get delete_selected;

  /// No description provided for @reduction.
  ///
  /// In zh, this message translates to:
  /// **'还原'**
  String get reduction;

  /// No description provided for @advanced_settings.
  ///
  /// In zh, this message translates to:
  /// **'高级设置'**
  String get advanced_settings;

  /// No description provided for @copy_to_tip.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get copy_to_tip;

  /// No description provided for @warning.
  ///
  /// In zh, this message translates to:
  /// **'警告'**
  String get warning;

  /// No description provided for @warning_different.
  ///
  /// In zh, this message translates to:
  /// **'系统 Hosts 文件与当前文件不一致！\n如果您不做覆盖处理，修改后保存当前文件会导致系统文件的数据被覆盖。'**
  String get warning_different;

  /// No description provided for @warning_different_covering_system.
  ///
  /// In zh, this message translates to:
  /// **'当前覆盖系统'**
  String get warning_different_covering_system;

  /// No description provided for @warning_different_covering_current.
  ///
  /// In zh, this message translates to:
  /// **'系统覆盖当前'**
  String get warning_different_covering_current;

  /// No description provided for @error_not_update_save_tip.
  ///
  /// In zh, this message translates to:
  /// **'内容已更新！请确保保存您的更改，以免丢失重要信息。'**
  String get error_not_update_save_tip;

  /// No description provided for @error_not_update_save_permission_tip.
  ///
  /// In zh, this message translates to:
  /// **'该文件已被使用保存时需要管理员权限。'**
  String get error_not_update_save_permission_tip;

  /// No description provided for @test.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get test;

  /// No description provided for @error_test_ip_notfound.
  ///
  /// In zh, this message translates to:
  /// **'未找到 IP 地址'**
  String get error_test_ip_notfound;

  /// No description provided for @error_test_ip_different.
  ///
  /// In zh, this message translates to:
  /// **'找到 IP 地址和设置 IP 地址并不一致'**
  String get error_test_ip_different;

  /// No description provided for @link.
  ///
  /// In zh, this message translates to:
  /// **'关联'**
  String get link;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @open_file.
  ///
  /// In zh, this message translates to:
  /// **'打开文件'**
  String get open_file;

  /// No description provided for @export.
  ///
  /// In zh, this message translates to:
  /// **'导出'**
  String get export;

  /// No description provided for @export_data.
  ///
  /// In zh, this message translates to:
  /// **'导出 Hosts 数据'**
  String get export_data;

  /// No description provided for @export_success.
  ///
  /// In zh, this message translates to:
  /// **'文件导出成功'**
  String get export_success;

  /// No description provided for @error_open_file.
  ///
  /// In zh, this message translates to:
  /// **'文件读取失败'**
  String get error_open_file;

  /// No description provided for @error_open_file_size.
  ///
  /// In zh, this message translates to:
  /// **'读取文件不能大于10MB'**
  String get error_open_file_size;

  /// No description provided for @about.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get about;

  /// No description provided for @about_description.
  ///
  /// In zh, this message translates to:
  /// **'Hosts Editor 是一个使用 Flutter 开发的应用程序，旨在简化 Linux、MacOS、Windows 系统上 hosts 文件的编辑和管理。\n该工具提供了一个用户友好的界面，使用户能够轻松地添加、修改和删除 hosts 文件中的条目。'**
  String get about_description;

  /// No description provided for @link_contrary.
  ///
  /// In zh, this message translates to:
  /// **'相反'**
  String get link_contrary;

  /// No description provided for @link_same.
  ///
  /// In zh, this message translates to:
  /// **'相同'**
  String get link_same;

  /// No description provided for @link_and_description.
  ///
  /// In zh, this message translates to:
  /// **'当 '**
  String get link_and_description;

  /// No description provided for @link_status_update_description.
  ///
  /// In zh, this message translates to:
  /// **' 状态变化时，下列数据切换为'**
  String get link_status_update_description;

  /// No description provided for @link_status_description.
  ///
  /// In zh, this message translates to:
  /// **'状态：'**
  String get link_status_description;

  /// No description provided for @form.
  ///
  /// In zh, this message translates to:
  /// **'表单'**
  String get form;

  /// No description provided for @import_data.
  ///
  /// In zh, this message translates to:
  /// **'导入 Hosts 数据'**
  String get import_data;

  /// No description provided for @import_success.
  ///
  /// In zh, this message translates to:
  /// **'导入成功'**
  String get import_success;

  /// No description provided for @loading.
  ///
  /// In zh, this message translates to:
  /// **'加载中'**
  String get loading;

  /// No description provided for @file_processing.
  ///
  /// In zh, this message translates to:
  /// **'文件处理中'**
  String get file_processing;

  /// No description provided for @import_file.
  ///
  /// In zh, this message translates to:
  /// **'导入文件'**
  String get import_file;

  /// No description provided for @will_overwrite.
  ///
  /// In zh, this message translates to:
  /// **'将覆盖现有文件'**
  String get will_overwrite;

  /// No description provided for @remote_sync.
  ///
  /// In zh, this message translates to:
  /// **'远程同步'**
  String get remote_sync;

  /// No description provided for @import.
  ///
  /// In zh, this message translates to:
  /// **'导入'**
  String get import;

  /// No description provided for @server_settings.
  ///
  /// In zh, this message translates to:
  /// **'服务器设置'**
  String get server_settings;

  /// No description provided for @server_status.
  ///
  /// In zh, this message translates to:
  /// **'服务器状态'**
  String get server_status;

  /// No description provided for @server_config.
  ///
  /// In zh, this message translates to:
  /// **'服务器配置'**
  String get server_config;

  /// No description provided for @server_running.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get server_running;

  /// No description provided for @server_stopped.
  ///
  /// In zh, this message translates to:
  /// **'已停止'**
  String get server_stopped;

  /// No description provided for @server_start.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get server_start;

  /// No description provided for @server_stop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get server_stop;

  /// No description provided for @server_restart.
  ///
  /// In zh, this message translates to:
  /// **'重启'**
  String get server_restart;

  /// No description provided for @server_host.
  ///
  /// In zh, this message translates to:
  /// **'主机地址'**
  String get server_host;

  /// No description provided for @server_port.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get server_port;

  /// No description provided for @server_auto_start.
  ///
  /// In zh, this message translates to:
  /// **'自动启动'**
  String get server_auto_start;

  /// No description provided for @server_auto_start_desc.
  ///
  /// In zh, this message translates to:
  /// **'应用启动时自动启动HTTP服务器'**
  String get server_auto_start_desc;

  /// No description provided for @server_save_config.
  ///
  /// In zh, this message translates to:
  /// **'保存配置'**
  String get server_save_config;

  /// No description provided for @server_copy_url.
  ///
  /// In zh, this message translates to:
  /// **'复制URL'**
  String get server_copy_url;

  /// No description provided for @server_url_copied.
  ///
  /// In zh, this message translates to:
  /// **'URL已复制到剪贴板'**
  String get server_url_copied;

  /// No description provided for @server_started.
  ///
  /// In zh, this message translates to:
  /// **'服务器已启动'**
  String get server_started;

  /// No description provided for @server_stopped_msg.
  ///
  /// In zh, this message translates to:
  /// **'服务器已停止'**
  String get server_stopped_msg;

  /// No description provided for @server_config_saved.
  ///
  /// In zh, this message translates to:
  /// **'配置保存成功'**
  String get server_config_saved;

  /// No description provided for @server_operation_failed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get server_operation_failed;

  /// No description provided for @server_invalid_port.
  ///
  /// In zh, this message translates to:
  /// **'端口号必须在1-65535之间'**
  String get server_invalid_port;

  /// No description provided for @server_invalid_host.
  ///
  /// In zh, this message translates to:
  /// **'主机地址不能为空'**
  String get server_invalid_host;

  /// No description provided for @api_docs.
  ///
  /// In zh, this message translates to:
  /// **'API文档'**
  String get api_docs;

  /// No description provided for @api_endpoints.
  ///
  /// In zh, this message translates to:
  /// **'可用的API端点'**
  String get api_endpoints;

  /// No description provided for @refresh_status.
  ///
  /// In zh, this message translates to:
  /// **'刷新状态'**
  String get refresh_status;

  /// No description provided for @server_address.
  ///
  /// In zh, this message translates to:
  /// **'服务器地址'**
  String get server_address;

  /// No description provided for @copy_url.
  ///
  /// In zh, this message translates to:
  /// **'复制URL'**
  String get copy_url;

  /// No description provided for @operation_failed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get operation_failed;

  /// No description provided for @load_server_settings_failed.
  ///
  /// In zh, this message translates to:
  /// **'加载服务器设置失败'**
  String get load_server_settings_failed;

  /// No description provided for @get_all_hosts_files.
  ///
  /// In zh, this message translates to:
  /// **'获取所有hosts文件'**
  String get get_all_hosts_files;

  /// No description provided for @get_specific_hosts_file.
  ///
  /// In zh, this message translates to:
  /// **'获取特定hosts文件内容（纯文本）'**
  String get get_specific_hosts_file;

  /// No description provided for @get_hosts_file_history.
  ///
  /// In zh, this message translates to:
  /// **'获取hosts文件历史记录'**
  String get get_hosts_file_history;

  /// No description provided for @get_specific_history_content.
  ///
  /// In zh, this message translates to:
  /// **'获取特定历史记录内容（纯文本）'**
  String get get_specific_history_content;

  /// No description provided for @server_already_running.
  ///
  /// In zh, this message translates to:
  /// **'服务器已经在运行中'**
  String get server_already_running;

  /// No description provided for @http_server_start_success.
  ///
  /// In zh, this message translates to:
  /// **'HTTP服务器启动成功'**
  String get http_server_start_success;

  /// No description provided for @http_server_start_failed.
  ///
  /// In zh, this message translates to:
  /// **'启动HTTP服务器失败'**
  String get http_server_start_failed;

  /// No description provided for @http_server_stopped.
  ///
  /// In zh, this message translates to:
  /// **'HTTP服务器已停止'**
  String get http_server_stopped;

  /// No description provided for @missing_file_id.
  ///
  /// In zh, this message translates to:
  /// **'缺少文件ID'**
  String get missing_file_id;

  /// No description provided for @read_file_failed.
  ///
  /// In zh, this message translates to:
  /// **'读取文件失败'**
  String get read_file_failed;

  /// No description provided for @missing_file_id_or_history_id.
  ///
  /// In zh, this message translates to:
  /// **'缺少文件ID或历史记录ID'**
  String get missing_file_id_or_history_id;

  /// No description provided for @history_not_found.
  ///
  /// In zh, this message translates to:
  /// **'历史记录不存在'**
  String get history_not_found;

  /// No description provided for @read_history_failed.
  ///
  /// In zh, this message translates to:
  /// **'读取历史记录失败'**
  String get read_history_failed;

  /// No description provided for @select_hosts_to_export.
  ///
  /// In zh, this message translates to:
  /// **'请选择要导出hosts文件'**
  String get select_hosts_to_export;

  /// No description provided for @select_all.
  ///
  /// In zh, this message translates to:
  /// **'全选'**
  String get select_all;

  /// No description provided for @selected_count.
  ///
  /// In zh, this message translates to:
  /// **'已选择'**
  String get selected_count;

  /// No description provided for @export_failed.
  ///
  /// In zh, this message translates to:
  /// **'导出失败'**
  String get export_failed;

  /// No description provided for @nearby_devices.
  ///
  /// In zh, this message translates to:
  /// **'附近设备'**
  String get nearby_devices;

  /// No description provided for @scan_nearby_devices.
  ///
  /// In zh, this message translates to:
  /// **'扫描附近设备'**
  String get scan_nearby_devices;

  /// No description provided for @no_nearby_devices.
  ///
  /// In zh, this message translates to:
  /// **'没有发现开启共享功能的设备\n点击刷新按钮扫描附近设备'**
  String get no_nearby_devices;

  /// No description provided for @scanning_devices.
  ///
  /// In zh, this message translates to:
  /// **'正在扫描附近设备...'**
  String get scanning_devices;

  /// No description provided for @sharing_enabled.
  ///
  /// In zh, this message translates to:
  /// **'共享服务已开启'**
  String get sharing_enabled;

  /// No description provided for @device_reachable.
  ///
  /// In zh, this message translates to:
  /// **'设备可达'**
  String get device_reachable;

  /// No description provided for @visit_device.
  ///
  /// In zh, this message translates to:
  /// **'访问设备'**
  String get visit_device;

  /// No description provided for @access_denied_file_not_allowed.
  ///
  /// In zh, this message translates to:
  /// **'访问被拒绝：文件不被允许'**
  String get access_denied_file_not_allowed;

  /// No description provided for @select_hosts_to_share.
  ///
  /// In zh, this message translates to:
  /// **'请选择要分享的hosts文件'**
  String get select_hosts_to_share;

  /// No description provided for @offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offline;

  /// No description provided for @scan_nearby_devices_failed.
  ///
  /// In zh, this message translates to:
  /// **'扫描附近设备失败'**
  String get scan_nearby_devices_failed;

  /// No description provided for @import_remote_hosts.
  ///
  /// In zh, this message translates to:
  /// **'导入远程hosts文件'**
  String get import_remote_hosts;

  /// No description provided for @refresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get refresh;

  /// No description provided for @getting_remote_hosts.
  ///
  /// In zh, this message translates to:
  /// **'正在获取远程hosts文件...'**
  String get getting_remote_hosts;

  /// No description provided for @connection_failed.
  ///
  /// In zh, this message translates to:
  /// **'连接设备失败'**
  String get connection_failed;

  /// No description provided for @retry.
  ///
  /// In zh, this message translates to:
  /// **'重试'**
  String get retry;

  /// No description provided for @no_hosts_files_found.
  ///
  /// In zh, this message translates to:
  /// **'没有找到可用的hosts文件'**
  String get no_hosts_files_found;

  /// No description provided for @device_no_shared_files.
  ///
  /// In zh, this message translates to:
  /// **'该设备可能没有共享任何hosts文件'**
  String get device_no_shared_files;

  /// No description provided for @no_importable_content.
  ///
  /// In zh, this message translates to:
  /// **'没有找到可导入的文件内容'**
  String get no_importable_content;

  /// No description provided for @remote_files.
  ///
  /// In zh, this message translates to:
  /// **'个远程文件'**
  String get remote_files;

  /// No description provided for @show_qr_code.
  ///
  /// In zh, this message translates to:
  /// **'显示二维码'**
  String get show_qr_code;

  /// No description provided for @port.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get port;

  /// No description provided for @hosts_diff_title.
  ///
  /// In zh, this message translates to:
  /// **'Hosts 差异对比'**
  String get hosts_diff_title;

  /// No description provided for @diff_legend_added.
  ///
  /// In zh, this message translates to:
  /// **'新增内容'**
  String get diff_legend_added;

  /// No description provided for @diff_legend_deleted.
  ///
  /// In zh, this message translates to:
  /// **'删除内容'**
  String get diff_legend_deleted;

  /// No description provided for @diff_legend_unchanged.
  ///
  /// In zh, this message translates to:
  /// **'未变更内容'**
  String get diff_legend_unchanged;

  /// No description provided for @diff_stats_history.
  ///
  /// In zh, this message translates to:
  /// **'历史版本'**
  String get diff_stats_history;

  /// No description provided for @diff_stats_current.
  ///
  /// In zh, this message translates to:
  /// **'当前版本'**
  String get diff_stats_current;

  /// No description provided for @diff_stats_difference.
  ///
  /// In zh, this message translates to:
  /// **'差异'**
  String get diff_stats_difference;

  /// No description provided for @history_count.
  ///
  /// In zh, this message translates to:
  /// **'历史记录'**
  String get history_count;

  /// No description provided for @getting_device_info.
  ///
  /// In zh, this message translates to:
  /// **'正在获取设备信息...'**
  String get getting_device_info;

  /// No description provided for @get_device_info_failed.
  ///
  /// In zh, this message translates to:
  /// **'获取设备信息失败'**
  String get get_device_info_failed;

  /// No description provided for @basic_api.
  ///
  /// In zh, this message translates to:
  /// **'基础 API'**
  String get basic_api;

  /// No description provided for @available_hosts_files_api.
  ///
  /// In zh, this message translates to:
  /// **'可用的Hosts文件 API：'**
  String get available_hosts_files_api;

  /// No description provided for @device_no_hosts_files.
  ///
  /// In zh, this message translates to:
  /// **'该设备暂无可用的hosts文件'**
  String get device_no_hosts_files;

  /// No description provided for @history_content.
  ///
  /// In zh, this message translates to:
  /// **'历史记录内容'**
  String get history_content;

  /// No description provided for @history_count_suffix.
  ///
  /// In zh, this message translates to:
  /// **'条历史'**
  String get history_count_suffix;

  /// No description provided for @get_content_prefix.
  ///
  /// In zh, this message translates to:
  /// **'获取'**
  String get get_content_prefix;

  /// No description provided for @get_content_suffix.
  ///
  /// In zh, this message translates to:
  /// **'的内容'**
  String get get_content_suffix;

  /// No description provided for @scan_qr_code_to_access.
  ///
  /// In zh, this message translates to:
  /// **'扫描二维码访问'**
  String get scan_qr_code_to_access;

  /// No description provided for @open_in_browser.
  ///
  /// In zh, this message translates to:
  /// **'在浏览器中打开'**
  String get open_in_browser;

  /// No description provided for @show_qr_code_tooltip.
  ///
  /// In zh, this message translates to:
  /// **'显示二维码'**
  String get show_qr_code_tooltip;

  /// No description provided for @copy_url_tooltip.
  ///
  /// In zh, this message translates to:
  /// **'复制URL'**
  String get copy_url_tooltip;

  /// No description provided for @get_history_content_prefix.
  ///
  /// In zh, this message translates to:
  /// **'获取历史记录'**
  String get get_history_content_prefix;

  /// No description provided for @get_history_content_suffix.
  ///
  /// In zh, this message translates to:
  /// **'的内容'**
  String get get_history_content_suffix;

  /// No description provided for @more_history_records.
  ///
  /// In zh, this message translates to:
  /// **'... 还有'**
  String get more_history_records;

  /// No description provided for @more_history_records_suffix.
  ///
  /// In zh, this message translates to:
  /// **'条历史记录'**
  String get more_history_records_suffix;

  /// No description provided for @view_diff.
  ///
  /// In zh, this message translates to:
  /// **'查看差异'**
  String get view_diff;

  /// No description provided for @history_version.
  ///
  /// In zh, this message translates to:
  /// **'历史版本'**
  String get history_version;

  /// No description provided for @current_version.
  ///
  /// In zh, this message translates to:
  /// **'当前版本'**
  String get current_version;

  /// No description provided for @unable_to_read_history_file.
  ///
  /// In zh, this message translates to:
  /// **'无法读取历史文件'**
  String get unable_to_read_history_file;

  /// No description provided for @diff_legend_description.
  ///
  /// In zh, this message translates to:
  /// **'差异说明'**
  String get diff_legend_description;

  /// No description provided for @diff_legend_ok.
  ///
  /// In zh, this message translates to:
  /// **'知道了'**
  String get diff_legend_ok;

  /// No description provided for @current_line.
  ///
  /// In zh, this message translates to:
  /// **'当前行：'**
  String get current_line;

  /// No description provided for @total_lines.
  ///
  /// In zh, this message translates to:
  /// **'总行数：'**
  String get total_lines;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}

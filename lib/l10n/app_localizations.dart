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

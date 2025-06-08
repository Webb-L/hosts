// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'Hosts Editor';

  @override
  String get ok => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get create => 'Create';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Delete';

  @override
  String get abort => 'Discard';

  @override
  String get remark => 'Remark';

  @override
  String get info => 'Information';

  @override
  String get input_remark => 'Please enter a remark';

  @override
  String remove_single_tip(Object name) {
    return 'Are you sure you want to delete \'$name\'?';
  }

  @override
  String remove_multiple_tip(Object count) {
    return 'Are you sure you want to delete the selected $count records?';
  }

  @override
  String get save => 'Save';

  @override
  String get save_create_history => 'Save and generate history';

  @override
  String get default_hosts_text => 'Default';

  @override
  String get input_search => 'Search...';

  @override
  String get use => 'Use';

  @override
  String get prev => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get ip_address => 'IP Address';

  @override
  String get input_ip_address => 'Please enter IP address';

  @override
  String get input_ip_address_hint => 'Supports IPV4 and IPV6';

  @override
  String get input_ipv4_ipv6 => 'Please enter IPV4 or IPV6 address';

  @override
  String get create_host_template =>
      'Template 1 - Not enabled:\n# 127.0.0.1 flutter.dev\n\nTemplate 2 - No remark:\n127.0.0.1 flutter.dev\n\nTemplate 3 - With remark:\n# Flutter\n127.0.0.1 flutter.dev\n\n...';

  @override
  String get history => 'History';

  @override
  String get domain => 'Domain';

  @override
  String get input_domain => 'Please enter domain';

  @override
  String get error_domain_tip =>
      'Please do not enter spaces (\' \') or new lines (\'\n\').';

  @override
  String get error_exist_domain_tip => 'This domain already exists';

  @override
  String get history_remove_tip =>
      'The history will be removed in 5 seconds. Click the button on the right to cancel.';

  @override
  String get error_null_data => 'No data found';

  @override
  String get error_use_fail => 'Use failed';

  @override
  String get error_not_save => 'The current file contains unsaved changes';

  @override
  String get error_save_fail => 'Save failed';

  @override
  String get table => 'Table';

  @override
  String get text => 'Text';

  @override
  String get copy => 'Copy';

  @override
  String get status => 'Status';

  @override
  String get action => 'Action';

  @override
  String get copy_selected => 'Copy selected';

  @override
  String get delete_selected => 'Delete selected';

  @override
  String get reduction => 'Restore';

  @override
  String get advanced_settings => 'Advanced Settings';

  @override
  String get copy_to_tip => 'Copied to clipboard';

  @override
  String get warning => 'Warning';

  @override
  String get warning_different =>
      'The system Hosts file is inconsistent with the current file!\nIf you do not handle the overwrite, saving the current file after modification will cause the system file data to be overwritten.';

  @override
  String get warning_different_covering_system => 'Currently covering system';

  @override
  String get warning_different_covering_current => 'System covering current';

  @override
  String get error_not_update_save_tip =>
      'Content has been updated! Please ensure to save your changes to avoid losing important information.';

  @override
  String get error_not_update_save_permission_tip =>
      'This file is in use and requires administrator permissions to save.';

  @override
  String get test => 'Test';

  @override
  String get error_test_ip_notfound => 'IP address not found';

  @override
  String get error_test_ip_different =>
      'Found IP address does not match the set IP address';

  @override
  String get link => 'Link';

  @override
  String get delete => 'Delete';

  @override
  String get open_file => 'Open file';

  @override
  String get error_open_file => 'Failed to read the file';

  @override
  String get error_open_file_size => 'The file size cannot exceed 10MB';

  @override
  String get about => 'About';

  @override
  String get about_description =>
      'Hosts Editor is an application developed using Flutter, designed to simplify the editing and management of the hosts file on Linux, MacOS, and Windows systems.\nThis tool provides a user-friendly interface that allows users to easily add, modify, and delete entries in the hosts file.';

  @override
  String get link_contrary => 'Contrary';

  @override
  String get link_same => 'Same';

  @override
  String get link_and_description => 'When ';

  @override
  String get link_status_update_description =>
      ' the status changes, the following data switches to';

  @override
  String get link_status_description => 'Status:';

  @override
  String get form => 'Form';
}

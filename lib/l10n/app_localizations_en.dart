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
  String get export => 'Export';

  @override
  String get export_data => 'Export hosts data';

  @override
  String get export_success => 'File exported successfully';

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

  @override
  String get import_data => 'Import Hosts Data';

  @override
  String get import_success => 'Import successful';

  @override
  String get loading => 'Loading';

  @override
  String get file_processing => 'Processing file';

  @override
  String get import_file => 'Import file';

  @override
  String get will_overwrite => 'Will overwrite existing file';

  @override
  String get remote_sync => 'Remote Sync';

  @override
  String get import => 'Import';

  @override
  String get server_settings => 'Server Settings';

  @override
  String get server_status => 'Server Status';

  @override
  String get server_config => 'Server Configuration';

  @override
  String get server_running => 'Running';

  @override
  String get server_stopped => 'Stopped';

  @override
  String get server_start => 'Start';

  @override
  String get server_stop => 'Stop';

  @override
  String get server_restart => 'Restart';

  @override
  String get server_host => 'Host Address';

  @override
  String get server_port => 'Port';

  @override
  String get server_auto_start => 'Auto Start';

  @override
  String get server_auto_start_desc =>
      'Automatically start HTTP server when app launches';

  @override
  String get server_save_config => 'Save Configuration';

  @override
  String get server_copy_url => 'Copy URL';

  @override
  String get server_url_copied => 'URL copied to clipboard';

  @override
  String get server_started => 'Server started';

  @override
  String get server_stopped_msg => 'Server stopped';

  @override
  String get server_config_saved => 'Configuration saved successfully';

  @override
  String get server_operation_failed => 'Operation failed';

  @override
  String get server_invalid_port => 'Port must be between 1-65535';

  @override
  String get server_invalid_host => 'Host address cannot be empty';

  @override
  String get api_docs => 'API Documentation';

  @override
  String get api_endpoints => 'Available API endpoints';

  @override
  String get refresh_status => 'Refresh status';

  @override
  String get server_address => 'Server address';

  @override
  String get copy_url => 'Copy URL';

  @override
  String get operation_failed => 'Operation failed';

  @override
  String get load_server_settings_failed => 'Failed to load server settings';

  @override
  String get get_all_hosts_files => 'Get all hosts files';

  @override
  String get get_specific_hosts_file =>
      'Get specific hosts file content (plain text)';

  @override
  String get get_hosts_file_history => 'Get hosts file history';

  @override
  String get get_specific_history_content =>
      'Get specific history content (plain text)';

  @override
  String get server_already_running => 'Server is already running';

  @override
  String get http_server_start_success => 'HTTP server started successfully';

  @override
  String get http_server_start_failed => 'Failed to start HTTP server';

  @override
  String get http_server_stopped => 'HTTP server stopped';

  @override
  String get missing_file_id => 'Missing file ID';

  @override
  String get read_file_failed => 'Failed to read file';

  @override
  String get missing_file_id_or_history_id => 'Missing file ID or history ID';

  @override
  String get history_not_found => 'History not found';

  @override
  String get read_history_failed => 'Failed to read history';

  @override
  String get select_hosts_to_export => 'Please select hosts files to export';

  @override
  String get select_all => 'Select All';

  @override
  String get selected_count => 'Selected';

  @override
  String get export_failed => 'Export failed';

  @override
  String get nearby_devices => 'Nearby Devices';

  @override
  String get scan_nearby_devices => 'Scan nearby devices';

  @override
  String get no_nearby_devices =>
      'No devices with sharing enabled found\nClick refresh button to scan nearby devices';

  @override
  String get scanning_devices => 'Scanning nearby devices...';

  @override
  String get sharing_enabled => 'Sharing service enabled';

  @override
  String get device_reachable => 'Device reachable';

  @override
  String get visit_device => 'Visit device';

  @override
  String get access_denied_file_not_allowed =>
      'Access denied: File not allowed';

  @override
  String get select_hosts_to_share => 'Please select hosts files to share';

  @override
  String get offline => 'Offline';

  @override
  String get scan_nearby_devices_failed => 'Failed to scan nearby devices';

  @override
  String get import_remote_hosts => 'Import remote hosts files';

  @override
  String get refresh => 'Refresh';

  @override
  String get getting_remote_hosts => 'Getting remote hosts files...';

  @override
  String get connection_failed => 'Failed to connect to device';

  @override
  String get retry => 'Retry';

  @override
  String get no_hosts_files_found => 'No available hosts files found';

  @override
  String get device_no_shared_files =>
      'This device may not be sharing any hosts files';

  @override
  String get no_importable_content => 'No importable file content found';

  @override
  String get remote_files => ' remote files';

  @override
  String get show_qr_code => 'Show QR Code';

  @override
  String get port => 'Port';

  @override
  String get hosts_diff_title => 'Hosts Diff Comparison';

  @override
  String get diff_legend_added => 'Added Content';

  @override
  String get diff_legend_deleted => 'Deleted Content';

  @override
  String get diff_legend_unchanged => 'Unchanged Content';

  @override
  String get diff_stats_history => 'Historical Version';

  @override
  String get diff_stats_current => 'Current Version';

  @override
  String get diff_stats_difference => 'Difference';

  @override
  String get history_count => 'History records';

  @override
  String get getting_device_info => 'Getting device information...';

  @override
  String get get_device_info_failed => 'Failed to get device information';

  @override
  String get basic_api => 'Basic API';

  @override
  String get available_hosts_files_api => 'Available Hosts files API:';

  @override
  String get device_no_hosts_files =>
      'This device has no available hosts files';

  @override
  String get history_content => 'History content';

  @override
  String get history_count_suffix => ' history records';

  @override
  String get get_content_prefix => 'Get';

  @override
  String get get_content_suffix => 'content';

  @override
  String get scan_qr_code_to_access => 'Scan QR code to access';

  @override
  String get open_in_browser => 'Open in browser';

  @override
  String get show_qr_code_tooltip => 'Show QR code';

  @override
  String get copy_url_tooltip => 'Copy URL';

  @override
  String get get_history_content_prefix => 'Get history record';

  @override
  String get get_history_content_suffix => 'content';

  @override
  String get more_history_records => '... ';

  @override
  String get more_history_records_suffix => ' more history records';

  @override
  String get view_diff => 'View diff';

  @override
  String get history_version => 'History version';

  @override
  String get current_version => 'Current version';

  @override
  String get unable_to_read_history_file => 'Unable to read history file';

  @override
  String get diff_legend_description => 'Difference Legend';

  @override
  String get diff_legend_ok => 'Got it';

  @override
  String get current_line => 'Current line:';

  @override
  String get total_lines => 'Total lines:';

  @override
  String unable_to_open(Object host) {
    return 'Unable to open $host';
  }

  @override
  String get check_for_updates => 'Check for Updates';

  @override
  String get report_issue => 'Report Issue';
}

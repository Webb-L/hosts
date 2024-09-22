import 'package:flutter/material.dart';
import 'package:hosts/model/host_file.dart';

abstract class HostBaseView extends StatelessWidget {
  final List<HostsModel> hosts;
  final List<HostsModel> selectHosts;
  final Function(int, HostsModel) onEdit;
  final Function(int, HostsModel) onLink;
  final Function(int, HostsModel) onChecked;
  final Function(List<HostsModel>) onDelete;
  final Function(List<HostsModel>) onToggleUse;
  final Function(String) onLaunchUrl;

  const HostBaseView({
    super.key,
    required this.hosts,
    required this.selectHosts,
    required this.onChecked,
    required this.onEdit,
    required this.onLink,
    required this.onDelete,
    required this.onToggleUse,
    required this.onLaunchUrl,
  });
}

import 'package:flutter/material.dart';
import 'package:hosts/widget/hosts_diff_viewer.dart';
import 'package:hosts/l10n/app_localizations.dart';

class HostsDiffPage extends StatelessWidget {
  final String historyContent;
  final String currentContent;
  final String historyLabel;
  final String currentLabel;

  const HostsDiffPage({
    Key? key,
    required this.historyContent,
    required this.currentContent,
    required this.historyLabel,
    required this.currentLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.hosts_diff_title ?? 'Hosts 差异对比'),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline),
            onPressed: () => _showDiffLegend(context),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 统计信息
            _buildDiffStats(historyContent, currentContent, context),
            SizedBox(height: 16),
            
            // 差异显示
            Expanded(
              child: HostsDiffViewer(
                oldContent: historyContent,
                newContent: currentContent,
                oldLabel: historyLabel,
                newLabel: currentLabel,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiffStats(String oldContent, String newContent, BuildContext context) {
    final oldLines = oldContent.split('\n').length;
    final newLines = newContent.split('\n').length;
    final diff = newLines - oldLines;
    
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            context,
            AppLocalizations.of(context)!.diff_stats_history ?? '历史版本',
            '$oldLines 行',
            Icons.history,
          ),
          _buildStatItem(
            context,
            AppLocalizations.of(context)!.diff_stats_current ?? '当前版本', 
            '$newLines 行',
            Icons.description,
          ),
          _buildStatItem(
            context,
            AppLocalizations.of(context)!.diff_stats_difference ?? '差异',
            '${diff > 0 ? '+' : ''}$diff 行',
            diff > 0 ? Icons.add : (diff < 0 ? Icons.remove : Icons.check),
            color: diff > 0 
                ? Theme.of(context).colorScheme.primary
                : (diff < 0 ? Theme.of(context).colorScheme.error : null),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDiffLegend(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('差异说明'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem(
              context,
              AppLocalizations.of(context)!.diff_legend_added ?? '新增内容',
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
            ),
            SizedBox(height: 8),
            _buildLegendItem(
              context,
              AppLocalizations.of(context)!.diff_legend_deleted ?? '删除内容',
              Theme.of(context).colorScheme.error,
              Theme.of(context).colorScheme.errorContainer.withOpacity(0.3),
              hasStrikethrough: true,
            ),
            SizedBox(height: 8),
            _buildLegendItem(
              context,
              AppLocalizations.of(context)!.diff_legend_unchanged ?? '未变更内容',
              Theme.of(context).colorScheme.onSurface,
              null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('知道了'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String text,
    Color textColor,
    Color? backgroundColor, {
    bool hasStrikethrough = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          decoration: hasStrikethrough ? TextDecoration.lineThrough : null,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
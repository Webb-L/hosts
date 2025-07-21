import 'package:flutter/material.dart';
import 'package:diff_match_patch/diff_match_patch.dart';

class HostsDiffViewer extends StatelessWidget {
  final String oldContent;
  final String newContent;
  final String? oldLabel;
  final String? newLabel;

  const HostsDiffViewer({
    Key? key,
    required this.oldContent,
    required this.newContent,
    this.oldLabel,
    this.newLabel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dmp = DiffMatchPatch();
    final diffs = dmp.diff(oldContent, newContent);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题栏
        if (oldLabel != null || newLabel != null)
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              children: [
                if (oldLabel != null) ...[
                  Icon(Icons.remove, color: theme.colorScheme.error, size: 16),
                  SizedBox(width: 4),
                  Expanded(child: Text(oldLabel!, style: theme.textTheme.labelMedium)),
                ],
                if (oldLabel != null && newLabel != null)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(Icons.compare_arrows, size: 16),
                  ),
                if (newLabel != null) ...[
                  Icon(Icons.add, color: theme.colorScheme.primary, size: 16),
                  SizedBox(width: 4),
                  Expanded(child: Text(newLabel!, style: theme.textTheme.labelMedium)),
                ],
              ],
            ),
          ),
        
        // 差异内容
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    height: 1.4,
                  ),
                  children: diffs.map((diff) => _buildDiffSpan(diff, theme)).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  TextSpan _buildDiffSpan(Diff diff, ThemeData theme) {
    switch (diff.operation) {
      case DIFF_INSERT:
        return TextSpan(
          text: diff.text,
          style: TextStyle(
            backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w500,
          ),
        );
      case DIFF_DELETE:
        return TextSpan(
          text: diff.text,
          style: TextStyle(
            backgroundColor: theme.colorScheme.errorContainer.withOpacity(0.3),
            color: theme.colorScheme.error,
            decoration: TextDecoration.lineThrough,
            fontWeight: FontWeight.w500,
          ),
        );
      default:
        return TextSpan(
          text: diff.text,
          style: TextStyle(color: theme.colorScheme.onSurface),
        );
    }
  }
}
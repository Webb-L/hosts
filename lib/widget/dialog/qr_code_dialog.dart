import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hosts/l10n/app_localizations.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// 二维码显示对话框
class QrCodeDialog extends StatelessWidget {
  final String url;
  final String? title;

  const QrCodeDialog({
    super.key,
    required this.url,
    this.title,
  });

  /// 显示二维码对话框
  static void show(
    BuildContext context, {
    required String url,
    String? title,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QrCodeDialog(
          url: url,
          title: title,
        );
      },
    );
  }

  /// 复制URL到剪贴板
  void _copyUrl(BuildContext context) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.server_url_copied),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title ?? AppLocalizations.of(context)!.copy_url),
      content: SizedBox(
        width: 250,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 二维码显示区域
            SizedBox(
              width: 200,
              height: 200,
              child: Center(
                child: QrImageView(
                  data: url,
                  version: QrVersions.auto,
                  size: 180.0,
                  backgroundColor: Colors.transparent,
                  eyeStyle: QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  dataModuleStyle: QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // URL文本显示
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                url,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(AppLocalizations.of(context)!.cancel),
        ),
        FilledButton.icon(
          onPressed: () {
            _copyUrl(context);
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.copy, size: 16),
          label: Text(AppLocalizations.of(context)!.copy),
        ),
      ],
    );
  }
}
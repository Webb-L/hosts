import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void deleteMultiple(
    BuildContext context, List<String> array, VoidCallback onRemove) {
  if (array.isEmpty) return;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(array.length == 1
        ? AppLocalizations.of(context)!.remove_single_tip(array.first)
        : AppLocalizations.of(context)!.remove_multiple_tip(array.length)),
    action: SnackBarAction(
      label: AppLocalizations.of(context)!.ok,
      onPressed: onRemove,
    ),
  ));
}

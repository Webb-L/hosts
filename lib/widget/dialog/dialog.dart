import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<String?> hostConfigDialog(BuildContext context,
    [String defaultText = ""]) {
  final TextEditingController remarkController =
      TextEditingController(text: defaultText);
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  return showDialog<String?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(defaultText.isEmpty
            ? AppLocalizations.of(context)!.create
            : AppLocalizations.of(context)!.edit),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: remarkController,
            maxLength: 30,
            validator: (value) {
              final text = value ?? "";
              if (text.isEmpty) {
                return AppLocalizations.of(context)!.input_remark;
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.remark,
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () async {
              if (!(formKey.currentState?.validate() ?? false)) return;
              Navigator.of(context).pop(remarkController.text);
            },
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      );
    },
  );
}

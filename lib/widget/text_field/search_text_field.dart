import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  final String text;
  final ValueChanged<String>? onChanged;
  const SearchTextField({super.key, required this.text, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: '搜索...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: text.isNotEmpty
            ? GestureDetector(
          child: const Icon(Icons.close),
          onTap: () {
            onChanged??('');
          },
        )
            : const SizedBox(),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class SearchTextField extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;

  const SearchTextField({
    super.key,
    required this.text,
    required this.onChanged,
  });

  @override
  State<SearchTextField> createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: widget.text);
    _textEditingController.addListener(() {
      widget.onChanged(_textEditingController.text);
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textEditingController,
      decoration: InputDecoration(
        hintText: '搜索...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: widget.text.isNotEmpty
            ? GestureDetector(
          child: const Icon(Icons.close),
          onTap: () {
            _textEditingController.clear();
            widget.onChanged('');
          },
        )
            : const SizedBox(),
      ),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
    );
  }
}

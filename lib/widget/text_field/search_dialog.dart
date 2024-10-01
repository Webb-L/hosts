import 'package:flutter/material.dart';

class SearchDialog extends StatefulWidget {
  const SearchDialog({super.key});

  @override
  _SearchDialogState createState() => _SearchDialogState();
}

class _SearchDialogState extends State<SearchDialog> {
  final TextEditingController _searchTextEditingController =
      TextEditingController();
  final TextEditingController _replaceTextEditingController =
      TextEditingController();
  bool regexChecked = false;
  bool caseSensitiveChecked = false;
  bool wholeWordChecked = false;

  @override
  void initState() {
    _searchTextEditingController.addListener(() {});

    _replaceTextEditingController.addListener(() {});
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _searchTextEditingController.dispose();
    _replaceTextEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                TextFormField(
                  controller: _searchTextEditingController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    suffix: Text(
                      "1/1",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    label: const Text("查询"),
                  ),
                ),
                TextFormField(
                  controller: _replaceTextEditingController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.find_replace),
                    label: Text("替换"),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () => setState(() {
                        regexChecked = !regexChecked;
                      }),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                            child: Checkbox(
                              value: regexChecked,
                              onChanged:
                                  (bool? value) {}, // Keep Checkbox disabled
                            ),
                          ),
                          const Text("正则表达式"),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () => setState(() {
                        caseSensitiveChecked = !caseSensitiveChecked;
                      }),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                            child: Checkbox(
                              value: caseSensitiveChecked,
                              onChanged:
                                  (bool? value) {}, // Keep Checkbox disabled
                            ),
                          ),
                          const Text("区分大小写"),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () => setState(() {
                        wholeWordChecked = !wholeWordChecked;
                      }),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IgnorePointer(
                            child: Checkbox(
                              value: wholeWordChecked,
                              onChanged:
                                  (bool? value) {}, // Keep Checkbox disabled
                            ),
                          ),
                          const Text("只匹配整个单词"),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_downward)),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.find_replace)),
                    IconButton(
                        onPressed: () {}, icon: const Icon(Icons.settings)),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    TextButton(onPressed: () {}, child: const Text("替换")),
                    TextButton(onPressed: () {}, child: const Text("全部替换")),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

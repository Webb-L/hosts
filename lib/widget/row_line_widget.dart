import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hosts/util/regexp_util.dart';
import 'package:hosts/widget/host_text_editing_controller.dart';

class RowLineWidget extends StatelessWidget {
  final HostTextEditingController textEditingController;
  final GlobalKey textFieldContainerKey;
  final ScrollController scrollController;
  final BuildContext context;

  const RowLineWidget({
    super.key,
    required this.textEditingController,
    required this.context,
    required this.textFieldContainerKey,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return buildRowLine();
  }

  Widget buildRowLine() {
    double textFieldContainerWidth = 0;
    final RenderBox? renderBox =
        textFieldContainerKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      textFieldContainerWidth = renderBox.size.width;
    }
    final TextStyle? titleMedium = Theme.of(context).textTheme.titleMedium;
    final TextSelection textSelection = textEditingController.selection;
    final List<String> lines = textEditingController.text.split('\n');
    final String text = textEditingController.text;

    final double fontSize = (titleMedium?.fontSize ?? 0);
    final double containerWidth =
        "${lines.length}".length * fontSize + fontSize;

    final Set<int> selectedLine = {};
    final String startText = text.substring(0, max(0, textSelection.start));
    final int startLineIndex = countNewlines(startText);
    final int endLineIndex = countNewlines(
        text.substring(0, max(0, min(textSelection.end, text.length))));

    for (int i = startLineIndex; i <= endLineIndex; i++) {
      selectedLine.add(i);
    }

    return Container(
      width: containerWidth,
      padding: const EdgeInsets.only(top: 4),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        controller: scrollController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(lines.length, (index) {
            final String line = lines[index];

            final TextPainter textPainter = TextPainter(
              text: TextSpan(
                text: line,
                style: titleMedium,
              ),
              textDirection: TextDirection.ltr,
            )..layout();

            final double width = textPainter.width + fontSize;

            return buildIndexedLineContainer(
              containerWidth,
              selectedLine.contains(index),
              "${index + 1}",
              line,
              () {
                final int length =
                    lines.sublist(0, index + 1).join("\n").length;
                textEditingController.updateUseStatus(
                    TextSelection(baseOffset: length, extentOffset: length));
              },
            );
          }),
        ),
      ),
    );
  }

  Widget buildIndexedLineContainer(
    double containerWidth,
    bool isSelected,
    String text,
    String line,
    GestureTapCallback? onTap,
  ) {
    final TextStyle? titleMedium = Theme.of(context).textTheme.titleMedium;
    final double fontSize = (titleMedium?.fontSize ?? 0);
    return InkWell(
      onTap: onTap,
      child: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 8),
        width: containerWidth,
        color: isSelected ? Theme.of(context).colorScheme.inversePrimary : null,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 2),
                buildConfigStatus(line, fontSize),
                const SizedBox(height: 2),
              ],
            ),
            Text(text, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }

  int countNewlines(String text) {
    return '\n'.allMatches(text).length;
  }

  Widget buildConfigStatus(String line, double fontSize) {
    final Match? matchConfig =
        RegExp(r"# - config \{([^{}]*)\}").firstMatch(line);

    if (!(matchConfig != null && !line.startsWith("#"))) {
      return const SizedBox();
    }

    final String config = matchConfig.group(0) ?? "";

    // 解析 hosts 配置
    final parts = line
        .replaceFirst("#", "")
        .split(RegExp(r"\s+"))
        .where((it) => it.trim().isNotEmpty)
        .toList();
    if (!((isValidIPv4(parts.first) || isValidIPv6(parts.first)))) {
      return const SizedBox();
    }

    try {
      Map<String, dynamic> configMap =
          jsonDecode(config.replaceFirst("# - config ", ""));

      bool isLink = false;
      if (configMap.isNotEmpty) {
        isLink = configMap["same"] != null && configMap["contrary"] != null;
      }

      if (isLink) {
        return Opacity(
          opacity: 0.3,
          child: Icon(Icons.link, size: fontSize),
        );
      }
    } catch (e) {}

    return const SizedBox();
  }
}

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hosts/util/regexp_util.dart';

class HostTextEditingController extends TextEditingController {
  final List<String> lines = [];

  int currLine = 0;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    bool? withComposing,
  }) {
    lines.clear();
    lines.addAll(text.split("\n"));

    this.currLine = countNewlines(
        text.substring(0, selection.start > 0 ? selection.start : 0));

    final children = <TextSpan>[];

    final Color errorColor = Theme.of(context).colorScheme.error;
    final Color onPrimaryContainerColor = Theme.of(context).colorScheme.primary;
    final Color outlineColor = Theme.of(context).colorScheme.outline;
    final Color primaryContainerColor =
        Theme.of(context).colorScheme.primaryContainer;

    final double fontSize =
        Theme.of(context).textTheme.titleMedium?.fontSize ?? 0;

    final TextStyle annotationStyle = TextStyle(
      color: outlineColor,
      fontSize: fontSize,
    );
    final TextStyle hostStyle = TextStyle(
        color: onPrimaryContainerColor,
        fontSize: fontSize,
        fontWeight: FontWeight.bold);

    final RegExp regExpConfig = RegExp(r"# - config \{([^{}]*)\}");

    final int currLine = countNewlines(
        text.substring(0, selection.start > 0 ? selection.start : 0));

    for (var entry in lines.asMap().entries) {
      int index = entry.key; // 获取索引
      String line = entry.value; // 获取每一行的内容
      // 匹配 # xxxxxxxxx
      if (line.replaceAll(RegExp(r"\s+"), "").startsWith("#")) {
        children.add(TextSpan(
            text: "$line\n",
            style: annotationStyle.copyWith(
              backgroundColor:
                  currLine == index ? outlineColor.withOpacity(0.1) : null,
            )));
        continue;
      }

      // 匹配 127.0.0.1 xxxxxx # xxxxxxx # - config xxxxx
      if ((isValidIPv4(line) || isValidIPv6(line))) {
        // 匹配 127.0.0.1 xxxxxxx # xxxxxx # - config xxxx
        final annotationIndex = line.indexOf("#");
        if (annotationIndex != -1) {
          children.add(
            TextSpan(
              text: line.substring(0, annotationIndex),
              style: hostStyle.copyWith(
                backgroundColor: currLine == index
                    ? onPrimaryContainerColor.withOpacity(0.1)
                    : null,
              ),
            ),
          );

          final Iterable<RegExpMatch> allMatches =
              regExpConfig.allMatches(line);

          if (allMatches.isNotEmpty) {
            children.add(TextSpan(
              text: line.substring(annotationIndex, allMatches.first.start),
              style: annotationStyle.copyWith(
                backgroundColor:
                    currLine == index ? outlineColor.withOpacity(0.1) : null,
              ),
            ));

            for (var value in allMatches) {
              children.add(
                TextSpan(
                  text: line.substring(value.start, value.end),
                  style: TextStyle(
                    color: primaryContainerColor,
                    backgroundColor: currLine == index
                        ? primaryContainerColor.withOpacity(0.3)
                        : null,
                  ),
                ),
              );
            }
          }

          // 匹配 127.0.0.1 xxxxxx # dsafjslfkdjkfjaskfs
          if (allMatches.isEmpty) {
            children.add(TextSpan(
              text: line.substring(annotationIndex),
              style: annotationStyle.copyWith(
                backgroundColor:
                    currLine == index ? outlineColor.withOpacity(0.1) : null,
              ),
            ));
          }
        }

        // 匹配 127.0.0.1 xxxxxx
        if (annotationIndex == -1) {
          children.add(
            TextSpan(
              text: line,
              style: hostStyle.copyWith(
                backgroundColor: currLine == index
                    ? onPrimaryContainerColor.withOpacity(0.1)
                    : null,
              ),
            ),
          );
        }

        children.add(const TextSpan(text: "\n"));
        continue;
      }

      children.add(
        TextSpan(
            text: "$line\n",
            style: TextStyle(
              color: errorColor,
              fontSize: fontSize,
              backgroundColor:
                  currLine == index ? errorColor.withOpacity(0.1) : null,
            )),
      );
    }

    return TextSpan(
      style: style?.copyWith(fontSize: fontSize),
      children: children,
    );
  }

  int countNewlines(String text) {
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\r?\n')).length - 1;
  }

  void updateUseStatus(TextSelection selection) {
    List<Map<String, dynamic>> commentUpdate = [];
    String startText = "";

    print("${selection.start} ${selection.end}");

    if (selection.start >= 0 && selection.start != selection.end) {
      startText = text.substring(0, min(selection.start, selection.end));
      final int startLineIndex = countNewlines(startText);
      final int endLineIndex =
          countNewlines(text.substring(0, max(selection.start, selection.end)));

      if (startLineIndex == endLineIndex) {
        commentUpdate.add(toggleComment(startLineIndex));
      } else {
        for (int i = startLineIndex; i <= endLineIndex; i++) {
          commentUpdate.add(toggleComment(i));
        }
      }
    } else {
      startText = text.substring(0, selection.start);
      commentUpdate.add(toggleComment(countNewlines(startText)));
    }

    // 判断光标是否在某一行的开头
    final int lastLineBreak = startText.lastIndexOf("\n");
    bool isAtLineStart = false;
    if (lastLineBreak > 0) {
      final int selectionStart = min(selection.start, selection.end);
      isAtLineStart =
          text.substring(lastLineBreak, min(selectionStart, selection.end)) ==
              "\n";
      // 单行 光标没有多选
      if (isAtLineStart &&
          commentUpdate.length == 1 &&
          selection.start == selection.end) {
        value = value.copyWith(text: lines.join("\n"));
        return;
      }

      // 单行 光标多选
      if (isAtLineStart &&
          commentUpdate.length == 1 &&
          selection.start != selection.end) {
        final bool isCommented = commentUpdate.first['isCommented'] ?? false;
        value = value.copyWith(
          text: lines.join("\n"),
          selection: selection.copyWith(
            baseOffset: selection.start,
            extentOffset: selection.end + (isCommented ? -2 : 2),
          ),
        );
        return;
      }
    }

    final Map<String, int> result = commentUpdate.fold<Map<String, int>>(
      {'commented': 0, 'uncommented': 0},
      (acc, item) {
        if (item['isCommented']) {
          acc['commented'] =
              (acc['commented'] ?? 0) + int.parse("${(item['count'] ?? 0)}");
        } else {
          acc['uncommented'] =
              (acc['uncommented'] ?? 0) + int.parse("${item['count'] ?? 0}");
        }
        return acc;
      },
    );

    final int updateCount =
        (result['uncommented'] ?? 0) - (result['commented'] ?? 0);

    // 多行 光标多选
    if (isAtLineStart &&
        commentUpdate.length > 1 &&
        selection.start != selection.end) {
      value = value.copyWith(
        text: lines.join("\n"),
        selection: selection.copyWith(
          baseOffset: selection.start,
          extentOffset: max(0, selection.end + updateCount),
        ),
      );
      return;
    }

    if (selection.start == selection.end && selection.start == 0) {
      value = value.copyWith(text: lines.join("\n"));
      return;
    }
    if (selection.start == 0 && selection.start != selection.end) {
      value = value.copyWith(
        text: lines.join("\n"),
        selection: selection.copyWith(
          baseOffset: 0,
          extentOffset: max(0, selection.end + updateCount),
        ),
      );
      return;
    }

    // 判断是否是第一行
    final int adjustment =
        commentUpdate.length > 1 ? (updateCount > 0 ? 2 : -2) : updateCount;
    final int baseOffset = max(0, selection.start + adjustment);
    value = value.copyWith(
      text: lines.join("\n"),
      selection: selection.copyWith(
        baseOffset: baseOffset,
        extentOffset: max(0, selection.end + updateCount),
      ),
    );
  }

  Map<String, dynamic> toggleComment(int lineIndex) {
    final Map<String, dynamic> result = {};

    final String line = lines[lineIndex];
    final bool isCommented = line.trim().startsWith("#");

    result["isCommented"] = isCommented;
    if (isCommented) {
      if (line.contains("# ")) {
        lines[lineIndex] = line.replaceFirst("# ", "");
        result["count"] = 2;
      } else {
        lines[lineIndex] = line.replaceFirst("#", "");
        result["count"] = 1;
      }
    } else {
      if (line.isEmpty) {
        lines[lineIndex] = "#";
        result["count"] = 1;
      } else if (line.startsWith(" ")) {
        lines[lineIndex] = "#$line";
        result["count"] = 1;
      } else {
        lines[lineIndex] = "# $line";
        result["count"] = 2;
      }
    }

    return result;
  }
}

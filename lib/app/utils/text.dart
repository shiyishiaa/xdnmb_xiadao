import 'package:flutter/material.dart' hide Element;
import 'package:get/get.dart';
import 'package:html_to_text/html_to_text.dart';

import 'regex.dart';
import 'size.dart';
import 'theme.dart';

typedef GetHiddenText = HiddenText Function();

class HiddenText {
  HtmlText? _text;

  bool _isVisible = false;

  HiddenText();

  void _trigger() => _isVisible = !_isVisible;

  void dispose() => _text?.dispose();
}

TextSpan onHiddenText_(
    {required BuildContext context,
    required Element element,
    required TextStyle textStyle,
    Color? hiddenColor,
    GetHiddenText? getHiddenText,
    VoidCallback? refresh,
    OnLinkTapCallback? onLinkTap}) {
  assert((getHiddenText != null && refresh != null && onLinkTap != null) ||
      (getHiddenText == null && refresh == null && onLinkTap == null));

  final content = element.innerHtml;
  final size = getTextSize(context, '啊$content', textStyle);

  if (getHiddenText != null && refresh != null && onLinkTap != null) {
    final hiddenText = getHiddenText();

    final text = HtmlText(
      context,
      content,
      onLinkTap: (context, link, text) {
        if (hiddenText._isVisible) {
          onLinkTap(context, link, text);
        } else {
          hiddenText._trigger();
          refresh();
        }
      },
      onTextTap: (context, text) {
        hiddenText._trigger();
        refresh();
      },
      onText: (context, text) => Regex.onText(text),
      onTextRecursiveParse: true,
      textStyle: textStyle,
      overrideTextStyle: TextStyle(
        decoration: hiddenText._isVisible ? null : TextDecoration.lineThrough,
        decorationColor: hiddenText._isVisible
            ? null
            : (hiddenColor ??
                (Get.isDarkMode ? AppTheme.colorDark : Colors.black)),
        decorationThickness: hiddenText._isVisible ? null : (size.height + 5.0),
      ),
    );

    hiddenText._text?.dispose();
    hiddenText._text = text;

    return text.toTextSpan();
  }

  return htmlToTextSpan(
    context,
    content,
    onText: (context, text) => Regex.onText(text),
    onTextRecursiveParse: true,
    textStyle: textStyle,
    overrideTextStyle: TextStyle(
      decoration: TextDecoration.lineThrough,
      decorationColor:
          hiddenColor ?? (Get.isDarkMode ? AppTheme.colorDark : Colors.black),
      decorationThickness: size.height + 5.0,
    ),
  );
}

String htmlToPlainText(BuildContext context, String html) =>
    htmlToTextSpan(context, html).toPlainText();
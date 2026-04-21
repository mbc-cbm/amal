import 'package:flutter/material.dart';

/// RTL layout utilities for Arabic and Urdu locales.
class RtlHelper {
  RtlHelper._();

  static bool isRtl(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return locale == 'ar' || locale == 'ur';
  }

  static TextDirection textDirection(BuildContext context) =>
      isRtl(context) ? TextDirection.rtl : TextDirection.ltr;

  static TextAlign textAlign(BuildContext context) =>
      isRtl(context) ? TextAlign.right : TextAlign.left;

  static CrossAxisAlignment startAlignment(BuildContext context) =>
      isRtl(context) ? CrossAxisAlignment.end : CrossAxisAlignment.start;
}

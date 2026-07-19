import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formats a day (without time) in the current locale, e.g. `10. 7. 2026`.
String formatDay(BuildContext context, DateTime date) =>
    DateFormat.yMd(Localizations.localeOf(context).toString()).format(date);

/// Formats a time of day in the current locale, e.g. `18:42`.
String formatTime(BuildContext context, DateTime date) =>
    DateFormat.Hm(Localizations.localeOf(context).toString()).format(date);

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Formats a day (without time) in the current locale, e.g. `10. 7. 2026`.
String formatDay(BuildContext context, DateTime date) =>
    DateFormat.yMd(Localizations.localeOf(context).toString()).format(date);

import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';

/// Injectable service for Durations, DateTimes, and displaying formatted timestamps

@injectable
class TimeService {
  MaterialLocalizations getLocalization(BuildContext context) {
    return MaterialLocalizations.of(context);
  }

  String getFormattedText(Duration duration, {bool includeHour = true}) {
    return includeHour
        ? "${duration.inHours}:${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60))}"
        : "${duration.inMinutes.remainder(60)}:${(duration.inSeconds.remainder(60).toString().padLeft(2, '0'))}";
  }

  DateTime getDateWithoutTime(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  String getTime(DateTime dateTime, {bool includeAm = true}) {
    return includeAm ? DateFormat.jm().format(dateTime) : DateFormat.jm().format(dateTime).replaceAll(' AM', '').replaceAll(' PM', '');
  }

  String getDayAbbreviation(DateTime dateTime) {
    return DateFormat(DateFormat.ABBR_WEEKDAY).format(dateTime);
  }

  String getShortDateTime(DateTime? dateTime, BuildContext context) {
    return dateTime != null ? getLocalization(context).formatShortDate(dateTime) : '';
  }

  String getDayOfMonthSuffix(int dayNum) {
    if (!(dayNum >= 1 && dayNum <= 31)) {
      throw Exception('Invalid day of month');
    }

    if (dayNum >= 11 && dayNum <= 13) {
      return 'th';
    }

    switch (dayNum % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

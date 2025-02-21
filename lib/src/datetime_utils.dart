import 'package:date/src/date.dart';
import 'package:intl/intl.dart';

extension DateTimeToDate on DateTime {

  Date toDate() {
    return Date.from(this);
  }

}

extension DateTimeSql on DateTime {

  dynamic get sql {
    if (this is Date) {
      return (this as Date).sql;
    }
    return this;
  }

}

extension DateFormatTryParse on DateFormat {

  String? tryFormat(DateTime? date) {
    return date==null ? null : format(date);
  }

  DateTime? tryParse(String? string) {
    try {
      return parse(string!);
    } catch (_) {
      return null;
    }
  }

}

DateTime dateTimeFromJson(int date) => DateTime.fromMillisecondsSinceEpoch(date, isUtc: false);

DateTime? dateTimeFromJsonNullable(int? date) => date == null ? null : dateTimeFromJson(date);

int dateTimeToJson(DateTime date) => date.millisecondsSinceEpoch;

int? dateTimeToJsonNullable(DateTime? date) => date?.millisecondsSinceEpoch;
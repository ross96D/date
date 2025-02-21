import 'package:date/src/date.dart';
import 'package:intl/intl.dart';

extension DateTimeToDate on DateTime {
  Date toDate() {
    return Date.from(this);
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
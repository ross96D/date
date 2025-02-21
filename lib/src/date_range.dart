import 'package:dartx/dartx.dart';
import 'package:date/date.dart';
import 'package:intl/intl.dart';

typedef DateRange = BaseRange<Date>;
typedef DateTimeRange = BaseRange<DateTime>;

class BaseRange<T extends DateTime> implements Comparable<Object?> {

  static DateFormat condensedFormat = DateFormat("dd/MM/yyyy");
  static DateFormat fullFormatUi = DateFormat("dd' de 'MMMM' del 'yyyy", "es");
  static DateFormat monthFormat = DateFormat("MMMM' del 'yyyy", "es");
  static DateFormat yearFormat = DateFormat("'Año' yyyy", "es");
  static DateFormat onlyMonthFormat = DateFormat("MMMM", "es");
  static DateFormat condensedMonthFormat = DateFormat("MMM yyyy", "es");

  final T _from;
  final T _to;
  final String? customName;

  BaseRange(T from, T to, {
    this.customName,
  })  : _from = from,
        _to = to;

  BaseRange<T> copyWith({
    T? from,
    T? to,
    String? customName,
  }){
    return BaseRange<T>(
      from ?? _from,
      to ?? _to,
      customName: customName ?? this.customName,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BaseRange
        && customName==other.customName
        && _from==other._from
        && _to==other._to;
  }

  @override
  int get hashCode => Object.hashAll([customName, _from, _to]);

  @override
  int compareTo(other) {
    if (other is BaseRange) {
      int result = getFrom().compareTo(other.getFrom());
      if (result==0) result = getTo().compareTo(other.getTo());
      return result;
    }
    return -1;
  }

  // int get differenceInMonths => getTo().difference(getFrom()).inDays ~/ 30;
  int get differenceInMonths {
    final from = getFrom();
    final to = getTo();
    return ((from.year*12+from.month) - (to.year*12+to.month)).abs();
  }

  bool get isSingleDay {
    return getFrom().isAtSameDayAs(getTo());
  }
  String toUIString({bool useCustom=true}){
    if (useCustom && customName!.isNotNullOrEmpty) {
      return customName!;
    } else {
      final from = getFrom();
      final to = getTo();
      if (from.isAtSameDayAs(to)) {
        return fullFormatUi.format(from);
      }
      if (from.year==to.year) {
        if (from.day==1 && to.day==to.lastDayOfMonth.day) {
          if (from.month==to.month) {
            return monthFormat.format(from).capitalize();
          }
          if (from.month==1 && to.month==12) {
            return yearFormat.format(from);
          }
        }
        if (from.month != to.month) {
          return "${onlyMonthFormat.format(from)} - ${onlyMonthFormat.format(to)} ${from.year}";
        }
      }
      String fromString = (from.month!=to.month || from.year!=to.year) && from.day==1
          ? condensedMonthFormat.format(from) : condensedFormat.format(from);
      String toString = (from.month!=to.month || from.year!=to.year) && to.day==to.lastDayOfMonth.day
          ? condensedMonthFormat.format(to) : condensedFormat.format(to);
      return "$fromString - $toString";
    }
  }

  T getFrom() => _from;

  T getTo() => _to;

  @override
  String toString() {
    return toUIString(useCustom: false);
  }

  bool isInThisRange(DateTime date) {
    final from = getFrom();
    final to = getTo();
    return (date.isAtSameDayAs(from) || date.isAfter(from))
        && (date.isAtSameDayAs(to) || date.isBefore(to));
  }


  static List<int> toJsonExternalDate(DateRange range) {
    return [
      0,
      range.getFrom().toJson(),
      range.getTo().toJson(),
    ];
  }
  static List<int>? toJsonExternalDateNullable(DateRange? range) {
    return range==null ? null : toJsonExternalDate(range);
  }
  static List<int> toJsonExternalDateTime(DateTimeRange range) {
    return [
      1,
      dateTimeToJson(range.getFrom()),
      dateTimeToJson(range.getTo()),
    ];
  }
  static List<int>? toJsonExternalDateTimeNullable(DateTimeRange? range) {
    return range==null ? null : toJsonExternalDateTime(range);
  }
  static List<int> toJsonExternal<T extends DateTime>(BaseRange<T> range) {
    if (T == Date) {
      return toJsonExternalDate(range as BaseRange<Date>);
    }
    return toJsonExternalDateTime(range);
  }
  static List<int>? toJsonExternalNullable<T extends DateTime>(BaseRange<T>? range) {
    return range != null ? toJsonExternal<T>(range) : null;
  }
  List<int> toJson() => toJsonExternal<T>(this);

  static DateRange fromJsonExternalDate(List<dynamic> json) {
    return DateRange(
      Date.fromJson(json[1] as int),
      Date.fromJson(json[2] as int),
    );
  }
  static DateRange? fromJsonExternalDateNullable(List<int>? range) {
    return range==null ? null : fromJsonExternalDate(range);
  }
  static DateTimeRange fromJsonExternalDateTime(List<dynamic> json) {
    return DateTimeRange(
      dateTimeFromJson(json[1] as int),
      dateTimeFromJson(json[2] as int),
    );
  }
  static DateTimeRange? fromJsonExternalDateTimeNullable(List<int>? range) {
    return range==null ? null : fromJsonExternalDateTime(range);
  }
  static BaseRange<T> fromJsonExternal<T extends DateTime>(List<dynamic> json) {
    if ((json[0] as int) == 0) {
      return fromJsonExternalDate(json) as BaseRange<T>;
    }
    return fromJsonExternalDateTime(json) as BaseRange<T>;
  }
  static BaseRange<T>? fromJsonExternalNullable<T extends DateTime>(List<dynamic>? json) {
    return json != null ? fromJsonExternal<T>(json) : null;
  }
  factory BaseRange.fromJson(dynamic json) => fromJsonExternal<T>(json);

}

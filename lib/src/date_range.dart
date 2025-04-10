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

  // null in from/to means the range doesn't have a lower/upper bound,
  // from=null and to=Date.now() means today and everything before
  // to=null from and to=Date.now() means today and everything after
  // double null shouldn't really happen, but it would mean all time unbound
  final T? _from;
  final T? _to;
  final String? customName;

  BaseRange(T? from, T? to, {
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
      final from = getFrom();
      final otherFrom = other.getFrom();
      int result = from==null
          ? otherFrom==null
              ? 0
              : -1
          : otherFrom==null
              ? 1
              : from.compareTo(otherFrom);
      if (result==0) {
        final to = getFrom();
        final otherTo = other.getFrom();
        result = to==null
            ? otherTo==null
                ? 0
                : -1
            : otherTo==null
                ? 1
                : to.compareTo(otherTo);
      }
      return result;
    }
    return -1;
  }

  // int get differenceInMonths => getTo().difference(getFrom()).inDays ~/ 30;
  int get differenceInMonths {
    final from = getFrom();
    final to = getTo();
    if (from==null || to==null) return double.maxFinite.toInt();
    return ((from.year*12+from.month) - (to.year*12+to.month)).abs();
  }

  bool get isSingleDay {
    final from = getFrom();
    final to = getTo();
    return from!=null && to!=null && from.isAtSameDayAs(to);
  }
  String toUIString({bool useCustom=true}){
    if (useCustom && customName.isNotNullOrBlank) {
      return customName!;
    }
    final from = getFrom();
    final to = getTo();
    if (from==null && to==null) {
      return 'Todos los tiempos';
    }
    if (from==null) {
      return 'Hasta ${condensedFormat.format(to!)}';
    }
    if (to==null) {
      return 'Desde ${condensedFormat.format(from)}';
    }
    if (from.isAtSameDayAs(to)) {
      return fullFormatUi.format(from);
    }
    if (from.year==to.year && from.day==1 && to.day==to.lastDayOfMonth.day) {
      if (from.month==to.month) {
        return monthFormat.format(from).capitalize();
      }
      if (from.month==1 && to.month==12) {
        return yearFormat.format(from);
      }
      return "${onlyMonthFormat.format(from)} - ${onlyMonthFormat.format(to)} ${from.year}";
    }
    String fromString = (from.month!=to.month || from.year!=to.year) && from.day==1
        ? condensedMonthFormat.format(from) : condensedFormat.format(from);
    String toString = (from.month!=to.month || from.year!=to.year) && to.day==to.lastDayOfMonth.day
        ? condensedMonthFormat.format(to) : condensedFormat.format(to);
    return "$fromString - $toString";
  }
  String toUIStringExact({bool useCustom=true}){
    if (useCustom && customName.isNotNullOrBlank) {
      return customName!;
    }
    final from = getFrom();
    final to = getTo();
    if (from==null && to==null) {
      return '';
    }
    if (from==null) {
      return condensedFormat.format(to!);
    }
    if (to==null) {
      return condensedFormat.format(from);
    }
    return "${condensedFormat.format(from)} - ${condensedFormat.format(to)}";
  }

  T? getFrom() => _from;

  T? getTo() => _to;

  Object? getSqlFrom() => getFrom()?.sql;
  Object? getSqlTo() => getTo()?.sql;
  Object? getSqlToSearch() {
    var to = getTo();
    if (to!=null && to is Date) { // we need to add 1 day so everything inside the date itself is included in sql search, otherwise it isn't
      to = to.copyWith(day: to.day + 1) as T;
    }
    return to?.sql;
  }

  @override
  String toString() {
    return toUIString(useCustom: false);
  }

  DateRange toDateRange() {
    if (this is DateRange) return (this as DateRange);
    return DateRange(getFrom()?.toDate(), getTo()?.toDate(),
      customName: customName,
    );
  }

  bool isInThisRange(DateTime date) {
    final from = getFrom();
    final to = getTo();
    return (from==null || date.isAtSameDayAs(from) || date.isAfter(from))
        && (to==null || date.isAtSameDayAs(to) || date.isBefore(to));
  }


  static List<int?> toJsonExternalDate(DateRange range) {
    return [
      0,
      range.getFrom()?.toJson(),
      range.getTo()?.toJson(),
    ];
  }
  static List<int?>? toJsonExternalDateNullable(DateRange? range) {
    return range==null ? null : toJsonExternalDate(range);
  }
  static List<int?> toJsonExternalDateTime(DateTimeRange range) {
    return [
      1,
      dateTimeToJsonNullable(range.getFrom()),
      dateTimeToJsonNullable(range.getTo()),
    ];
  }
  static List<int?>? toJsonExternalDateTimeNullable(DateTimeRange? range) {
    return range==null ? null : toJsonExternalDateTime(range);
  }
  static List<int?> toJsonExternal<T extends DateTime>(BaseRange<T> range) {
    if (T == Date) {
      return toJsonExternalDate(range as BaseRange<Date>);
    }
    return toJsonExternalDateTime(range);
  }
  static List<int?>? toJsonExternalNullable<T extends DateTime>(BaseRange<T>? range) {
    return range != null ? toJsonExternal<T>(range) : null;
  }
  List<int?> toJson() => toJsonExternal<T>(this);

  static DateRange fromJsonExternalDate(List<dynamic> json) {
    return DateRange(
      Date.fromJsonExternalNullable(json[1] as int?),
      Date.fromJsonExternalNullable(json[2] as int?),
    );
  }
  static DateRange? fromJsonExternalDateNullable(List<int>? range) {
    return range==null ? null : fromJsonExternalDate(range);
  }
  static DateTimeRange fromJsonExternalDateTime(List<dynamic> json) {
    return DateTimeRange(
      dateTimeFromJsonNullable(json[1] as int?),
      dateTimeFromJsonNullable(json[2] as int?),
    );
  }
  static DateTimeRange? fromJsonExternalDateTimeNullable(List<int?>? range) {
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

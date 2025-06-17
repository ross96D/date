import 'package:date/src/date_range.dart';
import 'package:date/date.dart';

typedef DerivedDateTransform<T extends DateTime> = T Function(T original);

class DerivedRange<T extends DateTime> extends BaseRange<T> {
  final BaseRange<T> originalDateRange;
  final DerivedDateTransform<T> transform;

  static DateTime defaultTransform(DateTime originalDate) {
    return originalDate.copyWith(year: originalDate.year - 1);
  }

  DerivedRange(
    this.originalDateRange, {
    required this.transform,
    super.customName,
  }) : super(originalDateRange.getFrom(), originalDateRange.getTo());

  @override
  DerivedRange<T> copyWith({
    BaseRange<T>? comparedDateRange,
    DerivedDateTransform<T>? transform,
    String? customName,
    // these arguments don't make sense here, but i'm forced to add them because of inheritance
    T? from,
    T? to,
  }) {
    return DerivedRange<T>(
      comparedDateRange ?? this.originalDateRange,
      transform: transform ?? this.transform,
      customName: customName ?? this.customName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DerivedRange) {
      return customName == other.customName &&
          originalDateRange == other.originalDateRange;
    }
    if (other is BaseRange) {
      return customName == other.customName &&
          getFrom() == other.getFrom() &&
          getTo() == other.getTo();
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([customName, originalDateRange]);

  @override
  T? getFrom() {
    final from = originalDateRange.getFrom();
    if (from == null) return null;
    return transform(from);
  }

  @override
  T? getTo() {
    final to = originalDateRange.getTo();
    if (to == null) return null;
    return transform(to);
  }
}

class DerivedDateRange extends DerivedRange<Date> {
  DerivedDateRange(
    super.originalDateRange, {
    super.transform = defaultTransform,
    super.customName,
  });

  static Date defaultTransform(Date originalDate) {
    return originalDate.copyWith(year: originalDate.year - 1);
  }
}

class DerivedDateTimeRange extends DerivedRange<DateTime> {
  DerivedDateTimeRange(
    super.originalDateRange, {
    super.transform = defaultTransform,
    super.customName,
  });

  static DateTime defaultTransform(DateTime originalDate) {
    return originalDate.copyWith(year: originalDate.year - 1);
  }
}

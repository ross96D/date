import 'package:date/src/date_range.dart';
import 'package:date/date.dart';

typedef DerivedDateRange = DerivedRange<Date>;
typedef DerivedDateTimeRange = DerivedRange<DateTime>;

typedef DerivedDateTransform<T extends DateTime> = T Function(T original);

class DerivedRange<T extends DateTime> extends BaseRange<T> {

  final BaseRange<T> originalDateRange;
  final DerivedDateTransform<T> transform;

  static T defaultTransform<T extends DateTime>(T originalDateRange) {
    return originalDateRange.copyWith(year: originalDateRange.year-1) as T;
  }

  DerivedRange(this.originalDateRange, {
    DerivedDateTransform<T>? transform,
    String? customName,
  })  : transform = transform ?? defaultTransform,
        super(originalDateRange.getFrom(), originalDateRange.getTo(),
          customName: customName,
        );

  @override
  DerivedRange<T> copyWith({
    BaseRange<T>? comparedDateRange,
    DerivedDateTransform<T>? transform,
    String? customName,
    // these arguments don't make sense here, but i'm forced to add them because of inheritance
    T? from,
    T? to,
  }){
    return DerivedRange<T>(
      comparedDateRange ?? this.originalDateRange,
      transform: transform ?? this.transform,
      customName: customName ?? this.customName,
    );
  }

  @override
  bool operator ==(Object other) {
    if (other is DerivedRange) {
      return customName==other.customName
          && originalDateRange==other.originalDateRange;
    }
    if (other is BaseRange) {
      return customName==other.customName
          && getFrom()==other.getFrom()
          && getTo()==other.getTo();
    }
    return false;
  }

  @override
  int get hashCode => Object.hashAll([customName, originalDateRange]);

  @override
  T getFrom() => transform(originalDateRange.getFrom());

  @override
  T getTo() => transform(originalDateRange.getTo());

}
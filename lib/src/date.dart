
// ignore_for_file: constant_identifier_names

import 'package:date/src/date_utils.dart';

/// Clase que representa día, mes y año solamente para facilitar el
/// trabajo con las fechas a traves de la red
///
/// Para insertar en la base de datos siempre usar la conversion a string
/// ya que el driver que usa fluent query (y probablemente todos los de dart)
/// solo reconocen tipos estandar.
/// 
/// Intentar usarlo de forma normal levanta una excepcion en el driver
/// a la hora de parsear el valor
class Date implements DateTime {

  // integer representation to be passed through network
  final int _setdays;

  @override
  late final int year = getYearsFromInternalRep(_setdays);

  @override
  late final int month = getMonthsFromInternalRep(year, _setdays);

  @override
  late final int day = _setdays - daysInYears(year) - daysInMonth(year, month);

  Date._fromRepresentation(this._setdays);

  /// El valor minimo de dia y mes es 1 siguiendo el estandar de DateTime
  Date(int year, [
    int month = 1,
    int day = 1,
  ]) : _setdays = getInternalRepresentation(year, month, day);

  Date.from(DateTime obj) : this(obj.year, obj.month, obj.day);

  Date.now() : this.from(DateTime.now());

  static Date? fromNullable(DateTime? obj) {
    if (obj == null) {
      return null;
    }
    return Date.from(obj);
  }

  static Date? dynam(dynamic obj) {
    if (obj == null) {
      return null;
    }
    return Date.from(obj);
  }

  Date copyWith({
    int? year,
    int? month,
    int? day,
  }) {
    return Date(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
    );
  }

  @override
  bool operator ==(other) => other is Date && _setdays== other._setdays;

  bool operator <(covariant Date other) => _setdays < other._setdays;

  bool operator >(covariant Date other) => _setdays > other._setdays;

  bool operator >=(covariant Date other) => _setdays >= other._setdays;

  bool operator <=(covariant Date other) => _setdays <= other._setdays;

  @override
  int get hashCode => _setdays.hashCode;

  @override
  int compareTo(Object other) {
    if (other is Date) {
      return _setdays.compareTo(other._setdays);
    } if (other is DateTime) {
      return toDateTime().compareTo(other);
    }
    return -1;
  }

  @override
  String toString() {
    return "$year-${month >= 10 ? "$month" : "0$month"}-${day >= 10 ? "$day" : "0$day"}";
  }

  DateTime toDateTime() => DateTime(year, month, day);

  String get sql => toString();

  /// retorna un [int] pq debe ser llamada dentro de un json, no para que devuelva un json
  /// 
  /// se nombra como toJson es para seguir el formato que se ha usado
  static int toJson(Date d) {
    return d._setdays;
  }

  static int? toJsonNullable(Date? d) {
    return d != null ? toJson(d) : null;
  }

  /// de la misma forma que [toJson] devuelve un [int], fromJson recibe un [int]
  static Date fromJson(int json) {
    return Date._fromRepresentation(json);
  }

  static Date? fromJsonNullable(int? json) {
    return json != null ? fromJson(json) : null;
  }

  static Date min(Date a, Date b) {
    return a>b ? b : a;
  }

  static Date max(Date a, Date b) {
    return a<b ? b : a;
  }

  //! esta funcion puede mejorarse el rendimiento usando [_internalRep].. pero realmente vale la pena ahora
  //! el problema con la implementacion actual es [_internalRep] asume siempre 31 dias para los meses
  //! por lo qu seria complicado usarlo para obtener los dias de diferencia
  @override
  Duration difference(DateTime other) {
    return DateTime(year, month, day).difference(DateTime(other.year, other.month, other.day));
  }

  /// Returns true if [this] occurs before [other].
  @override
  bool isBefore(DateTime other) {
    return other is Date ? this < other : toDateTime().isBefore(other);
  }

  /// Returns true if [this] occurs after [other].
  @override
  bool isAfter(DateTime other) {
    return other is Date ? this > other : toDateTime().isAfter(other);
  }

  //! esto puede alcanzar mejor rendimiento pero por ahora para obtener un resultado rapido se implementa asi
  /// Retorna otra instancia justo como la api de DateTime
  @override
  Date add(Duration duration) {
    return Date.from(toDateTime().add(duration));
  }

  @override
  Date subtract(Duration duration) {
    return Date.from(toDateTime().subtract(duration));
  }

  @override
  bool isAtSameMomentAs(DateTime other) {
    return other is Date ? this == other : toDateTime().isAtSameMomentAs(other);
  }

  @override
  int get millisecondsSinceEpoch => toDateTime().millisecondsSinceEpoch;

  @override
  int get microsecondsSinceEpoch => toDateTime().microsecondsSinceEpoch;

  @override
  String toIso8601String() => toDateTime().toIso8601String();

  @override
  bool get isUtc => true;

  @override
  int get hour => 0;

  @override
  int get minute => 0;

  @override
  int get second => 0;

  @override
  int get millisecond => 0;

  @override
  int get microsecond => 0;

  @override
  String get timeZoneName => 'NONE';

  @override
  Duration get timeZoneOffset => Duration.zero;


  @override
  DateTime toLocal() => toDateTime();

  @override
  DateTime toUtc() => DateTime(year, month, day);

  @override
  int get weekday => toDateTime().weekday;

}


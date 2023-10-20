
// ignore_for_file: constant_identifier_names

/// Clase que representa día, mes y año solamente para facilitar el
/// trabajo con las fechas a traves de la red
///
/// Para insertar en la base de datos siempre usar la conversion a string
/// ya que el driver que usa fluent query (y probablemente todos los de dart)
/// solo reconocen tipos estandar.
/// 
/// Intentar usarlo de forma normal levanta una excepcion en el driver
/// a la hora de parsear el valor
class Date implements Comparable<Date> {

  static getyears(int daysrep) {
    int totalDays;
    int aprox = (daysrep/365).floor() + 1;
    do {
      aprox -= 1;
      totalDays = daysInYears(aprox);
    } while (totalDays >= daysrep);
    return aprox;
  }
  int? _year;
  int get year {
    _year ??= getyears(_setdays);
    return _year!;
  }

  static getMonths(int year, int daysrep) {
    int days = daysInYears(year);
    days = daysrep - days;
    int n = 0;
    while (days > 0) {
      int dd =_Months.values[n].days(); 
      days -= dd;
      // leap year
      if (n == 1 && isLeap(year)) {
        days --;
      }
      n++;
    }
    return n;
  }
  int? _month;
  int get month {
    _month ??= getMonths(year, _setdays);
    return _month!;
  }

  int? _day;
  int get day {
    if (_day == null) {
      int days = daysInYears(year);
      days = _setdays - days;
      days = days - _daysInMonth(year, month);
      _day = days;
    }
    return _day!;
  }

  // integer representation to be pass arround through network
  late int _daysRep;
  int get _setdays => _daysRep;
  set _setdays(int days) {
    _day = null;
    _month = null;
    _year = null;
    _daysRep = days;
  }

  static int daysInYears(int year) {
    return 365 * year + leapYears(year - 1);
  }
  
  static int leapYears(int year) {
    return (year/4).floor() - (year/100).floor() + (year/400).floor();
  }

  static int _daysInMonth(int year, int month) {
    month -= 1;
    year += ((month)/ 12).floor();
    month = month - ((month)/ 12).floor() * 12;
    int days = 0;
    for (int i = 0; i < month; i++) {
      days += _Months.values[i].days();
      if (i == 1 && isLeap(year)) {
        days += 1;
      }
    }
    return days;
  }

  /// El valor minimo de dia y mes es 1 siguiendo el estandar de DateTime
  Date(int year, [
    int month = 1,
    int day = 1,
  ]) {
    month = month - 1;
    int addedYears = ((month)/ 12).floor(); 
    year += addedYears;
    month = month - (addedYears * 12);
    _setdays = daysInYears(year);
    
    if (month > 1 && isLeap(year)) {
      _setdays++;
    }

    for (int i = 0; i < month; i++) {
      _setdays += _Months.values[i].days();
    }

    _setdays += day;
  }

  static Date from(DateTime obj) {
    return Date(obj.year, obj.month, obj.day);
  }

  static Date? fromNullable(DateTime? obj) {
    if (obj == null) {
      return null;
    }
    return from(obj);
  }

  static Date? dynam(dynamic obj) {
    if (obj == null) {
      return null;
    }
    return from(obj);
  }

  Date._fromRepresentation(int rep) {
    _setdays = rep;
  }

  /// retorna un [int] pq debe ser llamada dentro de un json, no para que devuelva un json
  /// 
  /// se nombra como toJson es para seguir el formato que se ha usado
  static int toJson(Date d) {
    return d._setdays;
  }

  static int? toJsonNullable(Date? d) {
    return d != null ? toJson(d) : null;
  }

  static bool isLeap(int year) {
    if ((year % 4 == 0 && year % 100 != 0) || year % 400 == 0) {
      return true;
    } else {
      return false;
    }
  }


  //! esta funcion puede mejorarse el rendimiento usando [_internalRep].. pero realmente vale la pena ahora
  //! el problema con la implementacion actual es [_internalRep] asume siempre 31 dias para los meses
  //! por lo qu seria complicado usarlo para obtener los dias de diferencia
  Duration difference(Date other) {
    return DateTime(year, month, day).difference(DateTime(other.year, other.month, other.day));
  }

  static Date now() {
    var now = DateTime.now();
    return Date(now.year, now.month, now.day);
  }

  /// de la misma forma que [toJson] devuelve un [int], fromJson recive un [int]
  static Date fromJson(int json) {
    return Date._fromRepresentation(json);
  }

  static Date? fromJsonNullable(int? json) {
    return json != null ? fromJson(json) : null;
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
  String toString() {
    return "$year-${month >= 10 ? "$month" : "0$month"}-${day >= 10 ? "$day" : "0$day"}";
  }

  DateTime toDateTime() {
    return DateTime(year, month, day);
  }

  String get sql => toString();

  /// Returns true if [this] occurs before [other].
  bool isBefore(Date other) {
    return this < other;
  }

  /// Returns true if [this] occurs after [other].
  bool isAfter(Date other) {
    return this > other;
  }

  @override
  int compareTo(Object other) => other is! Date ? -1 : _setdays.compareTo(other._setdays);

  //! esto puede alcanzar mejor rendimiento pero por ahora para obtener un resultado rapido se implementa asi
  /// Retorna otra instancia justo como la api de DateTime
  Date add(Duration duration) {
    var dt = toDateTime();
    dt = dt.add(duration);
    return Date.from(dt);
  }
}

enum _Months {
  JANUARY,
  FEBRUARY,
  MARCH,
  APRIL,
  MAY,
  JUNE,
  JULY,
  AUGUST,
  SEPTEMBER,
  OCTOBER,
  NOVEMBER,
  DECEMBER;

  int days() {
    return switch (this) {      
      _Months.JANUARY => 31,
      _Months.FEBRUARY => 28,
      _Months.MARCH => 31,
      _Months.APRIL => 30,
      _Months.MAY => 31,
      _Months.JUNE => 30,
      _Months.JULY => 31,
      _Months.AUGUST => 31,
      _Months.SEPTEMBER => 30,
      _Months.OCTOBER => 31,
      _Months.NOVEMBER => 30,
      _Months.DECEMBER => 31,
    };
  } 
}

extension DateParsing on DateTime {
  Date toDate() {
    return Date.from(this);
  }
}

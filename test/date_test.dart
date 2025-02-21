import 'dart:math';

import 'package:date/date.dart';
import 'package:date/src/date_utils.dart';
import 'package:test/test.dart';

void main() {
  test('date tojson formJson consistency', () {
    var d1 = Date(2023, 1, 3);
    var d2 = Date.fromJson(Date.toJson(d1));

    expect (d1, d2);
    expect (d1.day, d2.day);
    expect (d1.month, d2.month);
    expect (d1.year, d2.year);
  });

  test("date operators", () {
    var d1 = Date(2023, 1, 5);
    var d2 = Date(2023, 2, 12);
    var d3 = Date(2023, 2, 12);

    expect (d1 < d2, true);
    expect (d2, d3);
    expect (d1 <= d3, true);
    expect (d2 <= d3, true);
    expect (d3 >= d1, true);
    expect (d3 >= d2, true);
    // esta notacion es siguiendo la api de DateTime
    expect (d1.compareTo(d3), -1); // -1 pq d1 pasa antes
    expect (d2.compareTo(d1), 1); // 1 pq d2 pasa despues
    expect (d2.compareTo(d3), 0); // 0 pq d2 y d3 ocurren al mismo tiempo
  });

  group("date string consistency", () {
    test("date to string", () {
      for (int i = 0; i < 10000; i++) {
        int year = Random.secure().nextInt(10000);
        int month = Random.secure().nextInt(12);
        int day = Random.secure().nextInt(28);
        if (day == 0) day = 28;
        var d1 = Date(year, month, day);
        if (month == 0) {month = 12; year--;}
        expect ("$d1", "$year-${month < 10 ? "0$month" : "$month"}-${day < 10 ? "0$day" : "$day"}");
      }

      var d1 = Date(2460, 3, 31);
      expect("$d1", "2460-03-31");

      var d2 = Date(2460, 2, 29);
      expect("$d2", "2460-02-29");

      var d3 = Date(2460, 2, 30);
      expect("$d3", "2460-03-01");    
    });
  });

  test("DateTime to Date", () {
    DateTime dt = DateTime(2023, 11, 23);
    Date d = Date.from(dt);
    var dt2 = d.toDateTime();
    expect (dt, dt2);

    dt = dt.add(Duration(days: 8));

    expect (Date.from(dt), Date(2023, 12, 1));

    var now = DateTime.now();
    var now2 = Date.now();

    expect (now2, Date.from(now));
  });

  test("bug on december 31", () {
    final d = DateTime(2020, 12, 31);
    Date date = Date.from(d);

    expect(date.toString(), "2020-12-31");
  });

  test('alalaa', () {
    final d = DateTime(7112, 2, 21);
    var date = Date.from(d);

    expect(date.toString(), "7112-02-21");
  });

  test("bug on january 1", () {
    final d = DateTime(2020, 1, 1);
    Date date = Date.from(d);

    print(date);
    expect(date.toString(), "2020-01-01");
  });

  test("days in year", () {
    // 0 no es considerado leap year.. tal vez sí deberia pero por ahora se queda así

    int days = daysInYears(1);
    expect(days, equals(365));

    days = daysInYears(3);
    expect(days, equals(365 * 3));

    // en el inicio del 4rto año aun no pasa el 29 de febrero por lo q no se adiciona 1 
    days = daysInYears(4);
    expect(days, equals(365 * 4));

    days = daysInYears(5);
    expect(days, equals(365 * 5 + 1));
  });
}
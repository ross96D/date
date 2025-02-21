
int getInternalRepresentation(int year, [
  int month = 1,
  int day = 1,
]) {
  month = month - 1;
  int addedYears = ((month)/ 12).floor();
  year += addedYears;
  month = month - (addedYears * 12);
  int setdays = daysInYears(year);
  if (month > 1 && isLeapYear(year)) {
    setdays++;
  }
  for (int i = 0; i < month; i++) {
    setdays += Month.values[i].days;
  }
  setdays += day;
  return setdays;
}

int getYearsFromInternalRep(int daysrep) {
  int totalDays;
  int aprox = (daysrep/365).floor() + 1;
  do {
    aprox -= 1;
    totalDays = daysInYears(aprox);
  } while (totalDays >= daysrep);
  return aprox;
}

int getMonthsFromInternalRep(int year, int daysrep) {
  int days = daysInYears(year);
  days = daysrep - days;
  int n = 0;
  while (days > 0) {
    int dd = Month.values[n].days;
    days -= dd;
    // leap year
    if (n == 1 && isLeapYear(year)) {
      days --;
    }
    n++;
  }
  return n;
}

int daysInYears(int year) {
  return 365 * year + leapYears(year - 1);
}

int daysInMonth(int year, int month) {
  month -= 1;
  year += ((month)/ 12).floor();
  month = month - ((month)/ 12).floor() * 12;
  int days = 0;
  for (int i = 0; i < month; i++) {
    days += Month.values[i].days;
    if (i == 1 && isLeapYear(year)) {
      days += 1;
    }
  }
  return days;
}

int leapYears(int year) {
  return (year/4).floor() - (year/100).floor() + (year/400).floor();
}

bool isLeapYear(int year) {
  return (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;
}

enum Month {
  january(31),
  february(28),
  march(31),
  april(30),
  may(31),
  june(30),
  july(31),
  august(31),
  september(30),
  october(31),
  november(30),
  december(31);

  final int days;
  const Month(this.days);
}
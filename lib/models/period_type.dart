enum PeriodType {
  week,
  month,
  year;

  String get label {
    switch (this) {
      case PeriodType.week:
        return 'Week';
      case PeriodType.month:
        return 'Maand';
      case PeriodType.year:
        return 'Jaar';
    }
  }
}

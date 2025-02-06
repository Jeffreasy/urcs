bool isToday(DateTime date) {
  final now = DateTime.now();
  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

List<DateTime> getDaysInMonth(DateTime month) {
  final last = DateTime(month.year, month.month + 1, 0);
  return List.generate(
    last.day,
    (index) => DateTime(month.year, month.month, index + 1),
  );
}

int getWeekNumber(DateTime date) {
  return date.difference(DateTime(date.year, 1, 1)).inDays ~/ 7 + 1;
}

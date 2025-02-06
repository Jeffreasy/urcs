class StatisticsException implements Exception {
  final String message;
  final String? details;

  StatisticsException(this.message, [this.details]);

  @override
  String toString() => details == null ? message : '$message: $details';
}

class AnnualNote {
  final String id;
  final String text;
  final DateTime date;
  final String authorId;
  final String? restaurantId;
  final int year;

  const AnnualNote({
    required this.id,
    required this.text,
    required this.date,
    required this.authorId,
    this.restaurantId,
    required this.year,
  });
}

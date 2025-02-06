import '../models/period_type.dart';

class TooltipService {
  static String getStatCardTooltip(String title, PeriodType periodType) {
    switch (title) {
      case 'Totaal Uren':
        return 'Totaal aantal gewerkte uren voor de geselecteerde ${periodType.label.toLowerCase()}';
      case 'Groei':
        return 'Procentuele groei in uren ten opzichte van dezelfde periode vorig jaar';
      case 'Bezetting':
        return 'Percentage van beschikbare uren dat is ingevuld (op basis van 8-urige werkdagen)';
      default:
        return '';
    }
  }

  static String getChartTooltip(PeriodType periodType) {
    switch (periodType) {
      case PeriodType.week:
        return 'Verdeling van uren per dag van de week';
      case PeriodType.month:
        return 'Verdeling van uren per dag van de maand';
      case PeriodType.year:
        return 'Verdeling van uren per maand van het jaar';
    }
  }
}

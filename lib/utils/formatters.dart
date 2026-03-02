import 'package:intl/intl.dart';
import '../models/template_model.dart';

final _currency = NumberFormat.currency(locale: 'es_MX', symbol: '\$');

String formatMoney(double amount) => _currency.format(amount);

String savingTypeLabel(SavingType type) {
  switch (type) {
    case SavingType.daily:
      return 'Diario';
    case SavingType.monthly:
      return 'Mensual';
    case SavingType.numbered:
      return 'Por Números';
  }
}

String periodLabel(SavingType type, int number) {
  switch (type) {
    case SavingType.daily:
      return 'Día $number';
    case SavingType.monthly:
      return 'Mes $number';
    case SavingType.numbered:
      return '#$number';
  }
}

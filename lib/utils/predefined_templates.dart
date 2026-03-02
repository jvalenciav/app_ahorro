import 'package:uuid/uuid.dart';
import '../models/template_model.dart';

const _uuid = Uuid();

SavingEntry _entry(int n, double amount) => SavingEntry(
      id: _uuid.v4(),
      number: n,
      amount: amount,
    );

/// Genera plantillas predefinidas frescas (sin progreso)
List<SavingTemplate> getPredefinedTemplates() {
  return [
    // 1. Ahorra 5,000 por números (1 al 20, montos variables)
    SavingTemplate(
      id: 'pre_5000_num',
      name: 'Ahorra \$5,000',
      description: 'Completa 20 aportaciones para llegar a tu meta.',
      totalAmount: 5000,
      savingType: SavingType.numbered,
      isPredefined: true,
      emoji: '💰',
      colorHex: '#4CAF50',
      entries: List.generate(
          20, (i) => _entry(i + 1, 250)), // 20 x 250 = 5000
    ),

    // 2. Ahorra 10,000 mensual (10 meses x 1000)
    SavingTemplate(
      id: 'pre_10000_mes',
      name: 'Ahorra \$10,000',
      description: '10 meses ahorrando \$1,000 cada mes.',
      totalAmount: 10000,
      savingType: SavingType.monthly,
      isPredefined: true,
      emoji: '📅',
      colorHex: '#2196F3',
      entries: List.generate(10, (i) => _entry(i + 1, 1000)),
    ),

    // 3. Reto 52 semanas (ahorro diario escalonado)
    SavingTemplate(
      id: 'pre_reto52',
      name: 'Reto 52 Semanas',
      description: 'Cada semana ahorras \$10 más que la anterior. ¡Desafíate!',
      totalAmount: 13780,
      savingType: SavingType.numbered,
      isPredefined: true,
      emoji: '🏆',
      colorHex: '#FF9800',
      entries: List.generate(52, (i) => _entry(i + 1, (i + 1) * 10.0)),
    ),

    // 4. Ahorra diario 30 días (50 pesos al día)
    SavingTemplate(
      id: 'pre_daily30',
      name: 'Ahorro Diario 30 Días',
      description: 'Separa \$50 cada día durante un mes.',
      totalAmount: 1500,
      savingType: SavingType.daily,
      isPredefined: true,
      emoji: '📆',
      colorHex: '#9C27B0',
      entries: List.generate(30, (i) => _entry(i + 1, 50)),
    ),

    // 5. Ahorra 20,000 (vacaciones)
    SavingTemplate(
      id: 'pre_vacaciones',
      name: 'Fondo Vacaciones',
      description: '12 meses ahorrando para tus próximas vacaciones.',
      totalAmount: 24000,
      savingType: SavingType.monthly,
      isPredefined: true,
      emoji: '✈️',
      colorHex: '#00BCD4',
      entries: List.generate(12, (i) => _entry(i + 1, 2000)),
    ),
  ];
}

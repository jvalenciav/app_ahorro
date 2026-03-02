import 'dart:convert';

enum SavingType { daily, monthly, numbered }

class SavingEntry {
  final String id;
  final int number;
  final double amount;
  bool completed;
  DateTime? completedAt;

  SavingEntry({
    required this.id,
    required this.number,
    required this.amount,
    this.completed = false,
    this.completedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'number': number,
        'amount': amount,
        'completed': completed,
        'completedAt': completedAt?.toIso8601String(),
      };

  factory SavingEntry.fromMap(Map<String, dynamic> map) => SavingEntry(
        id: map['id'],
        number: map['number'],
        amount: map['amount'].toDouble(),
        completed: map['completed'] ?? false,
        completedAt: map['completedAt'] != null
            ? DateTime.parse(map['completedAt'])
            : null,
      );
}

class SavingTemplate {
  final String id;
  String name;
  String description;
  double totalAmount;
  SavingType savingType;
  bool isPredefined;
  List<SavingEntry> entries;
  DateTime createdAt;
  String? emoji;
  String? colorHex;

  SavingTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.totalAmount,
    required this.savingType,
    required this.entries,
    this.isPredefined = false,
    DateTime? createdAt,
    this.emoji,
    this.colorHex,
  }) : createdAt = createdAt ?? DateTime.now();

  double get savedAmount =>
      entries.where((e) => e.completed).fold(0, (sum, e) => sum + e.amount);

  double get remainingAmount => totalAmount - savedAmount;

  double get progressPercentage =>
      totalAmount > 0 ? (savedAmount / totalAmount * 100).clamp(0, 100) : 0;

  int get completedEntries => entries.where((e) => e.completed).length;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'description': description,
        'totalAmount': totalAmount,
        'savingType': savingType.index,
        'isPredefined': isPredefined,
        'entries': entries.map((e) => e.toMap()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'emoji': emoji,
        'colorHex': colorHex,
      };

  factory SavingTemplate.fromMap(Map<String, dynamic> map) => SavingTemplate(
        id: map['id'],
        name: map['name'],
        description: map['description'],
        totalAmount: map['totalAmount'].toDouble(),
        savingType: SavingType.values[map['savingType']],
        isPredefined: map['isPredefined'] ?? false,
        entries: (map['entries'] as List)
            .map((e) => SavingEntry.fromMap(e))
            .toList(),
        createdAt: DateTime.parse(map['createdAt']),
        emoji: map['emoji'],
        colorHex: map['colorHex'],
      );

  String toJson() => jsonEncode(toMap());
  factory SavingTemplate.fromJson(String source) =>
      SavingTemplate.fromMap(jsonDecode(source));
}

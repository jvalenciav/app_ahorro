#!/bin/bash

# ===========================================
# SCRIPT DE CONFIGURACIÓN - APP AHORRO FLUTTER
# Ejecutar desde la carpeta raíz del proyecto "ahorro"
# ===========================================

echo "🚀 Configurando proyecto Flutter Ahorro..."

# ---- pubspec.yaml ----
cat > pubspec.yaml << 'PUBSPEC'
name: ahorro
description: App de control de ahorro personal
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  uuid: ^4.3.3
  intl: ^0.19.0
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  lottie: ^3.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
PUBSPEC

echo "✅ pubspec.yaml creado"

# ---- Crear carpetas ----
mkdir -p lib/models
mkdir -p lib/providers
mkdir -p lib/screens
mkdir -p lib/widgets
mkdir -p lib/utils
mkdir -p assets/images

echo "✅ Carpetas creadas"

# ---- lib/models/template_model.dart ----
cat > lib/models/template_model.dart << 'DART'
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
DART

echo "✅ template_model.dart creado"

# ---- lib/utils/predefined_templates.dart ----
cat > lib/utils/predefined_templates.dart << 'DART'
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
DART

echo "✅ predefined_templates.dart creado"

# ---- lib/providers/app_provider.dart ----
cat > lib/providers/app_provider.dart << 'DART'
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/template_model.dart';
import '../utils/predefined_templates.dart';

const _uuid = Uuid();

class AppProvider extends ChangeNotifier {
  String? _userName;
  bool _isFirstTime = true;
  List<SavingTemplate> _templates = [];

  String? get userName => _userName;
  bool get isFirstTime => _isFirstTime;
  List<SavingTemplate> get templates => _templates;

  List<SavingTemplate> get predefinedTemplates =>
      _templates.where((t) => t.isPredefined).toList();

  List<SavingTemplate> get customTemplates =>
      _templates.where((t) => !t.isPredefined).toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _userName = prefs.getString('user_name');
    _isFirstTime = prefs.getBool('is_first_time') ?? true;
    await _loadTemplates(prefs);
    notifyListeners();
  }

  Future<void> _loadTemplates(SharedPreferences prefs) async {
    final saved = prefs.getStringList('templates');
    if (saved != null && saved.isNotEmpty) {
      _templates = saved.map((s) => SavingTemplate.fromJson(s)).toList();
    } else {
      // Primera vez: cargar plantillas predefinidas
      _templates = getPredefinedTemplates();
      await _saveTemplates(prefs);
    }
  }

  Future<void> _saveTemplates([SharedPreferences? prefs]) async {
    prefs ??= await SharedPreferences.getInstance();
    await prefs.setStringList(
        'templates', _templates.map((t) => t.toJson()).toList());
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    _userName = name;
    _isFirstTime = false;
    await prefs.setString('user_name', name);
    await prefs.setBool('is_first_time', false);
    notifyListeners();
  }

  Future<void> toggleEntry(String templateId, String entryId) async {
    final template = _templates.firstWhere((t) => t.id == templateId);
    final entry = template.entries.firstWhere((e) => e.id == entryId);
    entry.completed = !entry.completed;
    entry.completedAt = entry.completed ? DateTime.now() : null;
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> addCustomTemplate(SavingTemplate template) async {
    _templates.add(template);
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> deleteTemplate(String templateId) async {
    _templates.removeWhere((t) => t.id == templateId);
    await _saveTemplates();
    notifyListeners();
  }

  Future<void> resetTemplate(String templateId) async {
    final template = _templates.firstWhere((t) => t.id == templateId);
    for (var entry in template.entries) {
      entry.completed = false;
      entry.completedAt = null;
    }
    await _saveTemplates();
    notifyListeners();
  }

  SavingTemplate createCustomTemplate({
    required String name,
    required String description,
    required double totalAmount,
    required SavingType savingType,
    required int periods,
    String? emoji,
    String? colorHex,
  }) {
    final amountPerPeriod = totalAmount / periods;
    return SavingTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      totalAmount: totalAmount,
      savingType: savingType,
      isPredefined: false,
      emoji: emoji ?? '🎯',
      colorHex: colorHex ?? '#607D8B',
      entries: List.generate(
          periods,
          (i) => SavingEntry(
                id: _uuid.v4(),
                number: i + 1,
                amount: amountPerPeriod,
              )),
    );
  }
}
DART

echo "✅ app_provider.dart creado"

# ---- lib/utils/formatters.dart ----
cat > lib/utils/formatters.dart << 'DART'
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
DART

echo "✅ formatters.dart creado"

# ---- lib/screens/onboarding_screen.dart ----
cat > lib/screens/onboarding_screen.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await context.read<AppProvider>().setUserName(name);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/welcome');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('💸', style: const TextStyle(fontSize: 64))
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .slideY(begin: -0.3),
              const SizedBox(height: 24),
              Text(
                'Bienvenido a\nAhorro App',
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
              const SizedBox(height: 12),
              Text(
                'Antes de comenzar, ¿cómo te llamas?',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.white54,
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
              const SizedBox(height: 48),
              TextField(
                controller: _controller,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Tu nombre...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: Color(0xFF4CAF50), width: 2),
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ).animate().fadeIn(delay: 600.ms, duration: 600.ms),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Empezar',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ).animate().fadeIn(delay: 800.ms, duration: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
DART

echo "✅ onboarding_screen.dart creado"

# ---- lib/screens/welcome_screen.dart ----
cat > lib/screens/welcome_screen.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = context.read<AppProvider>().userName ?? '';
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🎉', style: const TextStyle(fontSize: 80))
                .animate()
                .scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 32),
            Text(
              '¡Hola, $name!',
              style: GoogleFonts.poppins(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
            const SizedBox(height: 12),
            Text(
              'Listo para empezar a ahorrar 💪',
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: Colors.white54,
              ),
            ).animate().fadeIn(delay: 600.ms),
          ],
        ),
      ),
    );
  }
}
DART

echo "✅ welcome_screen.dart creado"

# ---- lib/screens/home_screen.dart ----
cat > lib/screens/home_screen.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/template_card.dart';
import 'create_template_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final name = provider.userName ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, $name 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Tus metas de ahorro',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      backgroundColor: const Color(0xFF4CAF50),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.predefinedTemplates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Text(
                    'Plantillas Predefinidas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => TemplateCard(
                      template: provider.predefinedTemplates[i]),
                  childCount: provider.predefinedTemplates.length,
                ),
              ),
            ],
            if (provider.customTemplates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text(
                    'Mis Plantillas',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      TemplateCard(template: provider.customTemplates[i]),
                  childCount: provider.customTemplates.length,
                ),
              ),
            ],
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => const CreateTemplateScreen()),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nueva Meta',
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
DART

echo "✅ home_screen.dart creado"

# ---- lib/screens/template_detail_screen.dart ----
cat > lib/screens/template_detail_screen.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';

class TemplateDetailScreen extends StatelessWidget {
  final SavingTemplate template;

  const TemplateDetailScreen({super.key, required this.template});

  Color get _color {
    if (template.colorHex == null) return const Color(0xFF4CAF50);
    final hex = template.colorHex!.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    // get fresh template from provider
    final t = provider.templates.firstWhere((x) => x.id == template.id,
        orElse: () => template);

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${t.emoji ?? ''} ${t.name}',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          PopupMenuButton<String>(
            iconColor: Colors.white,
            onSelected: (val) async {
              if (val == 'reset') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: const Color(0xFF1A2A3A),
                    title: Text('Reiniciar',
                        style: GoogleFonts.poppins(color: Colors.white)),
                    content: Text('¿Borrar todo el progreso?',
                        style: GoogleFonts.poppins(color: Colors.white70)),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Reiniciar',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (ok == true) {
                  await provider.resetTemplate(t.id);
                }
              } else if (val == 'delete' && !t.isPredefined) {
                await provider.deleteTemplate(t.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'reset', child: Text('Reiniciar progreso')),
              if (!t.isPredefined)
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statBox('Ahorrado', formatMoney(t.savedAmount),
                        const Color(0xFF4CAF50)),
                    _statBox('Restante', formatMoney(t.remainingAmount),
                        Colors.orange),
                    _statBox('Total', formatMoney(t.totalAmount), _color),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: t.progressPercentage / 100,
                    minHeight: 12,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(_color),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t.completedEntries}/${t.entries.length} completados',
                      style: GoogleFonts.poppins(
                          color: Colors.white54, fontSize: 12),
                    ),
                    Text(
                      '${t.progressPercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                          color: _color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Description
          if (t.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.description,
                  style: GoogleFonts.poppins(
                      color: Colors.white54, fontSize: 13),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Toca cada cuadro para marcar como ahorrado',
                style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
              ),
            ),
          ),
          // Grid of entries
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.9,
              ),
              itemCount: t.entries.length,
              itemBuilder: (context, i) {
                final entry = t.entries[i];
                return GestureDetector(
                  onTap: () => provider.toggleEntry(t.id, entry.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      color: entry.completed
                          ? _color.withOpacity(0.85)
                          : Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: entry.completed
                            ? _color
                            : Colors.white.withOpacity(0.12),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (entry.completed)
                          const Icon(Icons.check_circle,
                              color: Colors.white, size: 20)
                        else
                          Text(
                            periodLabel(t.savingType, entry.number),
                            style: GoogleFonts.poppins(
                                color: Colors.white54,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(entry.amount),
                          style: GoogleFonts.poppins(
                            color: entry.completed
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(String label, String value, Color color) {
    return Column(
      children: [
        Text(label,
            style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: GoogleFonts.poppins(
                color: color, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
DART

echo "✅ template_detail_screen.dart creado"

# ---- lib/screens/create_template_screen.dart ----
cat > lib/screens/create_template_screen.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import '../providers/app_provider.dart';
import '../utils/formatters.dart';

class CreateTemplateScreen extends StatefulWidget {
  const CreateTemplateScreen({super.key});

  @override
  State<CreateTemplateScreen> createState() => _CreateTemplateScreenState();
}

class _CreateTemplateScreenState extends State<CreateTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _periodsCtrl = TextEditingController(text: '12');

  SavingType _type = SavingType.monthly;
  String _emoji = '🎯';
  String _colorHex = '#4CAF50';

  final _emojis = ['🎯', '💰', '✈️', '🏠', '🚗', '📱', '🎓', '❤️', '🏆', '⭐'];
  final _colors = [
    '#4CAF50', '#2196F3', '#FF9800', '#9C27B0',
    '#F44336', '#00BCD4', '#607D8B', '#FF5722',
  ];

  double get _perPeriod {
    final total = double.tryParse(_amountCtrl.text) ?? 0;
    final periods = int.tryParse(_periodsCtrl.text) ?? 1;
    return periods > 0 ? total / periods : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Nueva Meta de Ahorro',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _label('Ícono'),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _emojis.length,
                  itemBuilder: (_, i) => GestureDetector(
                    onTap: () => setState(() => _emoji = _emojis[i]),
                    child: AnimatedContainer(
                      duration: 200.ms,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _emoji == _emojis[i]
                            ? Colors.white.withOpacity(0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _emoji == _emojis[i]
                              ? Colors.white54
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(_emojis[i],
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _label('Color'),
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _colors.length,
                  itemBuilder: (_, i) {
                    final hex = _colors[i].replaceAll('#', '');
                    final c = Color(int.parse('FF$hex', radix: 16));
                    return GestureDetector(
                      onTap: () => setState(() => _colorHex = _colors[i]),
                      child: AnimatedContainer(
                        duration: 200.ms,
                        margin: const EdgeInsets.only(right: 8),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _colorHex == _colors[i]
                                ? Colors.white
                                : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              _label('Nombre de la meta'),
              _field(_nameCtrl, 'Ej. Fondo emergencias',
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 16),
              _label('Descripción (opcional)'),
              _field(_descCtrl, 'Describe tu meta...', maxLines: 2),
              const SizedBox(height: 16),
              _label('Monto total a ahorrar (\$)'),
              _field(_amountCtrl, '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Número inválido';
                    if (double.parse(v) <= 0) return 'Debe ser mayor a 0';
                    return null;
                  }),
              const SizedBox(height: 16),
              _label('Tipo de ahorro'),
              Row(
                children: SavingType.values
                    .map((t) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = t),
                            child: AnimatedContainer(
                              duration: 200.ms,
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _type == t
                                    ? const Color(0xFF4CAF50).withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _type == t
                                      ? const Color(0xFF4CAF50)
                                      : Colors.white12,
                                ),
                              ),
                              child: Text(
                                savingTypeLabel(t),
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  color: _type == t
                                      ? const Color(0xFF4CAF50)
                                      : Colors.white54,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
              _label('Número de ${_type == SavingType.daily ? "días" : _type == SavingType.monthly ? "meses" : "aportaciones"}'),
              _field(_periodsCtrl, '12',
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    final n = int.tryParse(v);
                    if (n == null || n <= 0) return 'Debe ser al menos 1';
                    return null;
                  }),
              if (_perPeriod > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Aportación por período: ${formatMoney(_perPeriod)}',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF4CAF50), fontSize: 13),
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Crear Meta',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final template = context.read<AppProvider>().createCustomTemplate(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          totalAmount: double.parse(_amountCtrl.text),
          savingType: _type,
          periods: int.parse(_periodsCtrl.text),
          emoji: _emoji,
          colorHex: _colorHex,
        );
    await context.read<AppProvider>().addCustomTemplate(template);
    if (mounted) Navigator.pop(context);
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          filled: true,
          fillColor: Colors.white.withOpacity(0.07),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          errorStyle: const TextStyle(color: Colors.redAccent),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF4CAF50), width: 2),
          ),
        ),
      );
}

extension on Duration {
  Duration get ms => this;
}

extension IntMs on int {
  Duration get ms => Duration(milliseconds: this);
}
DART

echo "✅ create_template_screen.dart creado"

# ---- lib/widgets/template_card.dart ----
cat > lib/widgets/template_card.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/template_model.dart';
import '../screens/template_detail_screen.dart';
import '../utils/formatters.dart';

class TemplateCard extends StatelessWidget {
  final SavingTemplate template;
  const TemplateCard({super.key, required this.template});

  Color get _color {
    if (template.colorHex == null) return const Color(0xFF4CAF50);
    final hex = template.colorHex!.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final t = template;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => TemplateDetailScreen(template: t)),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _color.withOpacity(0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(t.emoji ?? '💰',
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                      Text(
                        savingTypeLabel(t.savingType) +
                            ' • ${t.entries.length} aportaciones',
                        style: GoogleFonts.poppins(
                            color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(formatMoney(t.savedAmount),
                        style: GoogleFonts.poppins(
                            color: _color,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    Text('de ${formatMoney(t.totalAmount)}',
                        style: GoogleFonts.poppins(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: t.progressPercentage / 100,
                minHeight: 6,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${t.progressPercentage.toStringAsFixed(0)}% completado',
              style: GoogleFonts.poppins(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
DART

echo "✅ template_card.dart creado"

# ---- lib/main.dart ----
cat > lib/main.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = AppProvider();
  await provider.init();
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const AhorroApp(),
    ),
  );
}

class AhorroApp extends StatelessWidget {
  const AhorroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'Ahorro App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF4CAF50),
        ),
      ),
      initialRoute: provider.isFirstTime ? '/onboarding' : '/home',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
DART

echo "✅ main.dart creado"
echo ""
echo "============================================"
echo "  ✅ Estructura del proyecto creada"
echo "  Ahora ejecuta: flutter pub get"
echo "============================================"
echo ""
echo "Ejecutando flutter pub get..."
flutter pub get
echo ""
echo "🎉 ¡Listo! Ejecuta: flutter run"

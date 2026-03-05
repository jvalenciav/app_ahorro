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

  // NUEVO: editar nombre, descripción, emoji y color
  Future<void> editTemplate({
    required String templateId,
    required String name,
    required String description,
    required String emoji,
    required String colorHex,
  }) async {
    final template = _templates.firstWhere((t) => t.id == templateId);
    template.name = name;
    template.description = description;
    template.emoji = emoji;
    template.colorHex = colorHex;
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
        ),
      ),
    );
  }

  SavingTemplate createCustomTemplateWithAmounts({
    required String name,
    required String description,
    required SavingType savingType,
    required List<double> amounts,
    String? emoji,
    String? colorHex,
  }) {
    final total = amounts.fold(0.0, (sum, a) => sum + a);
    return SavingTemplate(
      id: _uuid.v4(),
      name: name,
      description: description,
      totalAmount: total,
      savingType: savingType,
      isPredefined: false,
      emoji: emoji ?? '🎯',
      colorHex: colorHex ?? '#607D8B',
      entries: List.generate(
        amounts.length,
        (i) => SavingEntry(
          id: _uuid.v4(),
          number: i + 1,
          amount: amounts[i],
        ),
      ),
    );
  }
}

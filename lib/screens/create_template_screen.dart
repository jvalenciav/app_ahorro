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

  bool _customAmounts = false;
  List<TextEditingController> _customAmountControllers = [];

  final _emojis = ['🎯', '💰', '✈️', '🏠', '🚗', '📱', '🎓', '❤️', '🏆', '⭐'];
  final _colors = [
    '#4CAF50', '#2196F3', '#FF9800', '#9C27B0',
    '#F44336', '#00BCD4', '#607D8B', '#FF5722',
  ];

  int get _periods => int.tryParse(_periodsCtrl.text) ?? 0;
  double get _totalAmount => double.tryParse(_amountCtrl.text) ?? 0;
  double get _perPeriod => _periods > 0 ? _totalAmount / _periods : 0;
  double get _customTotal => _customAmountControllers.fold(
      0, (sum, c) => sum + (double.tryParse(c.text) ?? 0));

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _periodsCtrl.dispose();
    for (var c in _customAmountControllers) c.dispose();
    super.dispose();
  }

  void _rebuildCustomControllers() {
    final n = _periods.clamp(0, 365);
    final oldValues = _customAmountControllers.map((c) => c.text).toList();
    for (var c in _customAmountControllers) c.dispose();
    _customAmountControllers = List.generate(n, (i) {
      final ctrl = TextEditingController();
      if (i < oldValues.length && oldValues[i].isNotEmpty) {
        ctrl.text = oldValues[i];
      }
      return ctrl;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Nueva Meta de Ahorro',
            style: GoogleFonts.poppins(
                color: Colors.white, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
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
                      duration: const Duration(milliseconds: 180),
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
                      child: Text(_emojis[i], style: const TextStyle(fontSize: 24)),
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
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(right: 10),
                        width: 34,
                        height: 34,
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
              const SizedBox(height: 14),
              _label('Descripción (opcional)'),
              _field(_descCtrl, 'Describe tu meta...', maxLines: 2),
              const SizedBox(height: 14),
              _label('Tipo de ahorro'),
              Row(
                children: SavingType.values
                    .map((t) => Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _type = t),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.only(right: 6),
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
              const SizedBox(height: 14),
              _label(_type == SavingType.daily
                  ? 'Número de días'
                  : _type == SavingType.monthly
                      ? 'Número de meses'
                      : 'Número de aportaciones'),
              _field(
                _periodsCtrl,
                '12',
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {
                  if (_customAmounts) _rebuildCustomControllers();
                }),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  final n = int.tryParse(v);
                  if (n == null || n <= 0) return 'Al menos 1';
                  if (n > 365) return 'Máximo 365';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              // Toggle modo montos
              _modeToggle(),
              const SizedBox(height: 14),
              // Monto igual
              if (!_customAmounts) ...[
                _label('Monto total a ahorrar (\$)'),
                _field(
                  _amountCtrl,
                  '0.00',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Requerido';
                    if (double.tryParse(v) == null) return 'Número inválido';
                    if (double.parse(v) <= 0) return 'Mayor a 0';
                    return null;
                  },
                ),
                if (_perPeriod > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _chip(
                        '${_type == SavingType.daily ? "Diario" : _type == SavingType.monthly ? "Mensual" : "Por número"}: ${formatMoney(_perPeriod)}'),
                  ),
              ],
              // Montos personalizados
              if (_customAmounts && _periods > 0) ...[
                _customAmountsSection(),
                const SizedBox(height: 8),
                _chip('Total acumulado: ${formatMoney(_customTotal)}'),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text('Crear Meta',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeToggle() => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _toggleOpt(
              label: '💵  Monto igual',
              selected: !_customAmounts,
              onTap: () => setState(() => _customAmounts = false),
            ),
            _toggleOpt(
              label: '🎛️  Montos distintos',
              selected: _customAmounts,
              onTap: () => setState(() {
                _customAmounts = true;
                _rebuildCustomControllers();
              }),
            ),
          ],
        ),
      );

  Widget _toggleOpt({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) =>
      Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFF4CAF50).withOpacity(0.25)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(
                color: selected ? const Color(0xFF4CAF50) : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: selected ? const Color(0xFF4CAF50) : Colors.white38,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      );

  Widget _customAmountsSection() {
    final n = _periods.clamp(0, 365);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Monto por aportación (\$)'),
        Text(
          'Define cuánto ahorrarás en cada ${_type == SavingType.daily ? "día" : _type == SavingType.monthly ? "mes" : "número"}',
          style: GoogleFonts.poppins(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _quickBtn('Llenar igual', _showFillDialog),
            const SizedBox(width: 8),
            _quickBtn('Escalonado', _showStepDialog),
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: n,
          itemBuilder: (_, i) {
            final label = _type == SavingType.daily
                ? 'Día ${i + 1}'
                : _type == SavingType.monthly
                    ? 'Mes ${i + 1}'
                    : 'Núm. ${i + 1}';
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  SizedBox(
                    width: 76,
                    child: Text(label,
                        style: GoogleFonts.poppins(
                            color: Colors.white60, fontSize: 13)),
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _customAmountControllers[i],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: Colors.white),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (!_customAmounts) return null;
                        if (v == null || v.isEmpty) return 'Req.';
                        if (double.tryParse(v) == null) return 'Inv.';
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: const TextStyle(color: Colors.white24),
                        prefixText: '\$ ',
                        prefixStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.07),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        errorStyle: const TextStyle(
                            color: Colors.redAccent, fontSize: 10),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                              color: Color(0xFF4CAF50), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _quickBtn(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Text(label,
              style:
                  GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
        ),
      );

  void _showFillDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        title: Text('Llenar con monto igual',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
        content: _dialogField(ctrl, 'Monto para cada período'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: GoogleFonts.poppins(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50)),
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null && v > 0) {
                setState(() {
                  for (var c in _customAmountControllers) {
                    c.text = v.toStringAsFixed(2);
                  }
                });
              }
              Navigator.pop(context);
            },
            child: Text('Aplicar',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStepDialog() {
    final baseCtrl = TextEditingController();
    final stepCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A2A3A),
        title: Text('Llenado escalonado',
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Núm.1 = base\nNúm.2 = base + incremento\nNúm.3 = base + incremento×2...',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 12),
            _dialogField(baseCtrl, 'Monto base (primera aportación)'),
            const SizedBox(height: 10),
            _dialogField(stepCtrl, 'Incremento por período'),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar',
                  style: GoogleFonts.poppins(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50)),
            onPressed: () {
              final base = double.tryParse(baseCtrl.text) ?? 0;
              final step = double.tryParse(stepCtrl.text) ?? 0;
              if (base > 0) {
                setState(() {
                  for (int i = 0; i < _customAmountControllers.length; i++) {
                    _customAmountControllers[i].text =
                        (base + step * i).toStringAsFixed(2);
                  }
                });
              }
              Navigator.pop(context);
            },
            child: Text('Aplicar',
                style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController ctrl, String hint) => TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
          prefixText: '\$ ',
          prefixStyle: const TextStyle(color: Colors.white54),
          filled: true,
          fillColor: Colors.white.withOpacity(0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );

  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF4CAF50).withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border:
              Border.all(color: const Color(0xFF4CAF50).withOpacity(0.4)),
        ),
        child: Text(text,
            style: GoogleFonts.poppins(
                color: const Color(0xFF4CAF50),
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      );

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appProvider = context.read<AppProvider>();

    if (_customAmounts) {
      if (_customTotal <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('La suma de montos debe ser mayor a 0')),
        );
        return;
      }
      final amounts = _customAmountControllers
          .map((c) => double.tryParse(c.text) ?? 0)
          .toList();
      final template = appProvider.createCustomTemplateWithAmounts(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        savingType: _type,
        amounts: amounts,
        emoji: _emoji,
        colorHex: _colorHex,
      );
      await appProvider.addCustomTemplate(template);
    } else {
      final template = appProvider.createCustomTemplate(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        totalAmount: double.parse(_amountCtrl.text),
        savingType: _type,
        periods: _periods,
        emoji: _emoji,
        colorHex: _colorHex,
      );
      await appProvider.addCustomTemplate(template);
    }

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

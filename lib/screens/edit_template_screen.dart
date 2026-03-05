import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/formatters.dart';

class EditTemplateScreen extends StatefulWidget {
  final SavingTemplate template;
  const EditTemplateScreen({super.key, required this.template});

  @override
  State<EditTemplateScreen> createState() => _EditTemplateScreenState();
}

class _EditTemplateScreenState extends State<EditTemplateScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late String _emoji;
  late String _colorHex;

  final _emojis = ['🎯', '💰', '✈️', '🏠', '🚗', '📱', '🎓', '❤️', '🏆', '⭐'];
  final _colors = [
    '#4CAF50', '#2196F3', '#FF9800', '#9C27B0',
    '#F44336', '#00BCD4', '#607D8B', '#FF5722',
  ];

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.template.name);
    _descCtrl = TextEditingController(text: widget.template.description);
    _emoji = widget.template.emoji ?? '🎯';
    _colorHex = widget.template.colorHex ?? '#4CAF50';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2A3A);
    final subColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Plantilla',
            style: GoogleFonts.poppins(
                color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info: solo nombre, descripción, emoji y color se pueden editar
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Solo puedes editar el nombre, descripción, ícono y color. El progreso se mantiene.',
                        style: GoogleFonts.poppins(
                            color: Colors.orange, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              _label('Ícono', subColor),
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
                      child: Text(_emojis[i],
                          style: const TextStyle(fontSize: 24)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _label('Color', subColor),
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

              _label('Nombre de la meta', subColor),
              _field(_nameCtrl, 'Nombre...', textColor: textColor,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Requerido' : null),
              const SizedBox(height: 14),

              _label('Descripción', subColor),
              _field(_descCtrl, 'Descripción...', textColor: textColor, maxLines: 3),
              const SizedBox(height: 14),

              // Datos no editables (solo vista)
              _label('Información de la meta', subColor),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _readOnlyRow('Tipo', savingTypeLabel(widget.template.savingType), textColor, subColor),
                    const SizedBox(height: 8),
                    _readOnlyRow('Aportaciones', '${widget.template.entries.length}', textColor, subColor),
                    const SizedBox(height: 8),
                    _readOnlyRow('Monto Total', formatMoney(widget.template.totalAmount), textColor, subColor),
                    const SizedBox(height: 8),
                    _readOnlyRow('Progreso', '${widget.template.progressPercentage.toStringAsFixed(1)}%', textColor, subColor),
                  ],
                ),
              ),
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
                  child: Text('Guardar Cambios',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
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

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AppProvider>().editTemplate(
          templateId: widget.template.id,
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          emoji: _emoji,
          colorHex: _colorHex,
        );
    if (mounted) Navigator.pop(context);
  }

  Widget _label(String text, Color color) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text,
            style: GoogleFonts.poppins(
                color: color, fontSize: 14, fontWeight: FontWeight.w500)),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    required Color textColor,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        style: TextStyle(color: textColor),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.withOpacity(0.1),
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

  Widget _readOnlyRow(String label, String value, Color textColor, Color subColor) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.poppins(color: subColor, fontSize: 13)),
          Text(value,
              style: GoogleFonts.poppins(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ],
      );
}

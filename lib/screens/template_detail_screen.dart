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

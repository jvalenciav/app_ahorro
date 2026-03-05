import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/formatters.dart';
import 'edit_template_screen.dart';

class TemplateDetailScreen extends StatelessWidget {
  final SavingTemplate template;
  const TemplateDetailScreen({super.key, required this.template});

  Color _templateColor(SavingTemplate t) {
    if (t.colorHex == null) return const Color(0xFF4CAF50);
    final hex = t.colorHex!.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;
    final t = provider.templates.firstWhere((x) => x.id == template.id,
        orElse: () => template);
    final color = _templateColor(t);
    final textColor = isDark ? Colors.white : const Color(0xFF1A2A3A);
    final subColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${t.emoji ?? ''} ${t.name}',
          style: GoogleFonts.poppins(
              color: textColor, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: IconThemeData(color: textColor),
        actions: [
          // Botón editar
          IconButton(
            icon: Icon(Icons.edit_outlined, color: color),
            tooltip: 'Editar',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditTemplateScreen(template: t)),
            ),
          ),
          PopupMenuButton<String>(
            iconColor: textColor,
            onSelected: (val) async {
              if (val == 'reset') {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor:
                        isDark ? const Color(0xFF1A2A3A) : Colors.white,
                    title: Text('Reiniciar',
                        style: GoogleFonts.poppins(color: textColor)),
                    content: Text('¿Borrar todo el progreso?',
                        style: GoogleFonts.poppins(color: subColor)),
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
                if (ok == true) await provider.resetTemplate(t.id);
              } else if (val == 'delete' && !t.isPredefined) {
                await provider.deleteTemplate(t.id);
                if (context.mounted) Navigator.pop(context);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                  value: 'reset', child: Text('Reiniciar progreso')),
              if (!t.isPredefined)
                const PopupMenuItem(
                    value: 'delete',
                    child: Text('Eliminar',
                        style: TextStyle(color: Colors.red))),
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
              color: color.withOpacity(isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statBox('Ahorrado', formatMoney(t.savedAmount),
                        const Color(0xFF4CAF50), subColor),
                    _statBox('Restante', formatMoney(t.remainingAmount),
                        Colors.orange, subColor),
                    _statBox('Total', formatMoney(t.totalAmount), color, subColor),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: t.progressPercentage / 100,
                    minHeight: 12,
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${t.completedEntries}/${t.entries.length} completados',
                      style: GoogleFonts.poppins(color: subColor, fontSize: 12),
                    ),
                    Text(
                      '${t.progressPercentage.toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (t.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(t.description,
                    style: GoogleFonts.poppins(color: subColor, fontSize: 13)),
              ),
            ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Toca cada cuadro para marcar como ahorrado',
                style: GoogleFonts.poppins(color: subColor, fontSize: 12),
              ),
            ),
          ),
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
                          ? color.withOpacity(0.85)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: entry.completed
                            ? color
                            : Colors.grey.withOpacity(0.2),
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
                                color: subColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        const SizedBox(height: 4),
                        Text(
                          formatMoney(entry.amount),
                          style: GoogleFonts.poppins(
                            color: entry.completed ? Colors.white : subColor,
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

  Widget _statBox(String label, String value, Color color, Color subColor) =>
      Column(
        children: [
          Text(label,
              style: GoogleFonts.poppins(color: subColor, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(
                  color: color, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      );
}

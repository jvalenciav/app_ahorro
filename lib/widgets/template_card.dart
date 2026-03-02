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

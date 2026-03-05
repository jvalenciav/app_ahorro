import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/formatters.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = context.watch<ThemeProvider>().isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2A3A);
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final cardColor = isDark ? const Color(0xFF1A2A3A) : Colors.white;

    final templates = provider.templates;
    final totalGoal = templates.fold(0.0, (s, t) => s + t.totalAmount);
    final totalSaved = templates.fold(0.0, (s, t) => s + t.savedAmount);
    final totalRemaining = totalGoal - totalSaved;
    final globalProgress = totalGoal > 0 ? totalSaved / totalGoal : 0.0;
    final completed = templates.where((t) => t.progressPercentage >= 100).length;
    final inProgress = templates.where((t) => t.progressPercentage > 0 && t.progressPercentage < 100).length;
    final notStarted = templates.where((t) => t.progressPercentage == 0).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Estadísticas',
            style: GoogleFonts.poppins(
                color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Resumen global ----
            _sectionTitle('Resumen Global', subColor),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _bigStat('Total Meta', formatMoney(totalGoal),
                          const Color(0xFF4CAF50), textColor),
                      _bigStat('Ahorrado', formatMoney(totalSaved),
                          Colors.greenAccent, textColor),
                      _bigStat('Restante', formatMoney(totalRemaining),
                          Colors.orange, textColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    children: [
                      Container(
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: globalProgress.clamp(0.0, 1.0),
                        child: Container(
                          height: 14,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(globalProgress * 100).toStringAsFixed(1)}% del total ahorrado',
                    style: GoogleFonts.poppins(
                        color: const Color(0xFF4CAF50),
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Estado de metas ----
            _sectionTitle('Estado de Metas', subColor),
            const SizedBox(height: 12),
            Row(
              children: [
                _statusCard('Completadas', completed, const Color(0xFF4CAF50),
                    Icons.check_circle_rounded, cardColor, textColor),
                const SizedBox(width: 10),
                _statusCard('En Progreso', inProgress, Colors.orange,
                    Icons.timelapse_rounded, cardColor, textColor),
                const SizedBox(width: 10),
                _statusCard('Sin Iniciar', notStarted, Colors.grey,
                    Icons.radio_button_unchecked, cardColor, textColor),
              ],
            ),
            const SizedBox(height: 24),

            // ---- Detalle por plantilla ----
            _sectionTitle('Detalle por Meta', subColor),
            const SizedBox(height: 12),
            if (templates.isEmpty)
              Center(
                child: Text('No hay metas aún',
                    style: GoogleFonts.poppins(color: subColor)),
              )
            else
              ...templates.map((t) {
                Color tColor = const Color(0xFF4CAF50);
                if (t.colorHex != null) {
                  final hex = t.colorHex!.replaceAll('#', '');
                  tColor = Color(int.parse('FF$hex', radix: 16));
                }
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDark
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(t.emoji ?? '💰',
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(t.name,
                                style: GoogleFonts.poppins(
                                    color: textColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14),
                                overflow: TextOverflow.ellipsis),
                          ),
                          Text(
                            '${t.progressPercentage.toStringAsFixed(0)}%',
                            style: GoogleFonts.poppins(
                                color: tColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: t.progressPercentage / 100,
                          minHeight: 8,
                          backgroundColor:
                              tColor.withOpacity(isDark ? 0.15 : 0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(tColor),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ahorrado: ${formatMoney(t.savedAmount)}',
                            style: GoogleFonts.poppins(
                                color: subColor, fontSize: 11),
                          ),
                          Text(
                            'Meta: ${formatMoney(t.totalAmount)}',
                            style: GoogleFonts.poppins(
                                color: subColor, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, Color color) => Text(
        text,
        style: GoogleFonts.poppins(
            color: color, fontSize: 15, fontWeight: FontWeight.w600),
      );

  Widget _bigStat(String label, String value, Color valueColor, Color labelColor) =>
      Column(
        children: [
          Text(label,
              style: GoogleFonts.poppins(color: labelColor.withOpacity(0.5), fontSize: 11)),
          const SizedBox(height: 4),
          Text(value,
              style: GoogleFonts.poppins(
                  color: valueColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
        ],
      );

  Widget _statusCard(String label, int count, Color color, IconData icon,
          Color cardColor, Color textColor) =>
      Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(height: 6),
              Text('$count',
                  style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              Text(label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: textColor.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        ),
      );
}

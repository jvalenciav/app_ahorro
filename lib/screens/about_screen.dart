import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/theme_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  Future<void> _openLinkedIn() async {
    final uri = Uri.parse('https://www.linkedin.com/in/juancarlosvalenciav/');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2A3A);
    final subColor = isDark ? Colors.white54 : Colors.black45;
    final cardColor = isDark ? const Color(0xFF1A2A3A) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text('Acerca de',
            style: GoogleFonts.poppins(
                color: textColor, fontWeight: FontWeight.bold)),
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // ---- Logo / Ícono ----
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.4), width: 2),
              ),
              child: const Center(
                child: Text('💸', style: TextStyle(fontSize: 48)),
              ),
            ),
            const SizedBox(height: 20),
            Text('Mi Ahorrito',
                style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            Text('v1.0.0',
                style: GoogleFonts.poppins(color: subColor, fontSize: 13)),
            const SizedBox(height: 8),
            Text(
              'Tu compañero para alcanzar\ntus metas de ahorro',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: subColor, fontSize: 14),
            ),
            const SizedBox(height: 36),

            // ---- Tarjeta del desarrollador ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text('JV',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Juan Carlos Valencia Villena',
                      style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Mto. en Gestión de Tecnologías de la Información',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF4CAF50),
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _openLinkedIn,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A66C2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.link, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text('LinkedIn',
                              style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ---- Info de la app ----
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ],
              ),
              child: Column(
                children: [
                  _infoRow(Icons.phone_android_rounded, 'Plataforma',
                      'Android', textColor, subColor),
                  _divider(isDark),
                  _infoRow(Icons.savings_rounded, 'Propósito',
                      'Control de ahorro personal', textColor, subColor),
                  _divider(isDark),
                  _infoRow(Icons.calendar_today_rounded, 'Año', '2026',
                      textColor, subColor),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Hecho con ❤️ en México',
                style: GoogleFonts.poppins(color: subColor, fontSize: 13)),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, Color textColor,
          Color subColor) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 20),
            const SizedBox(width: 12),
            Text(label,
                style: GoogleFonts.poppins(color: subColor, fontSize: 13)),
            const Spacer(),
            Text(value,
                style: GoogleFonts.poppins(
                    color: textColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      );

  Widget _divider(bool isDark) => Divider(
        color: isDark ? Colors.white10 : Colors.black.withOpacity(0.07),
        height: 1,
      );
}

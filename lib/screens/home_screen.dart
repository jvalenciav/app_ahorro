import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/template_card.dart';
import 'create_template_screen.dart';
import 'stats_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final name = provider.userName ?? '';
    final isDark = themeProvider.isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2A3A);
    final subColor = isDark ? Colors.white54 : Colors.black45;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ---- HEADER ----
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hola, $name 👋',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Tus metas de ahorro',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: subColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Botón estadísticas
                    IconButton(
                      onPressed: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const StatsScreen())),
                      icon: Icon(Icons.bar_chart_rounded, color: const Color(0xFF4CAF50)),
                      tooltip: 'Estadísticas',
                    ),
                    // Toggle tema
                    IconButton(
                      onPressed: () => themeProvider.toggle(),
                      icon: Icon(
                        isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: isDark ? Colors.amber : const Color(0xFF1A2A3A),
                      ),
                      tooltip: 'Cambiar tema',
                    ),
                    // Menú
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: subColor),
                      onSelected: (val) {
                        if (val == 'about') {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const AboutScreen()));
                        }
                      },
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: 'about',
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18),
                              const SizedBox(width: 8),
                              Text('Acerca de',
                                  style: GoogleFonts.poppins(fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ---- PLANTILLAS PREDEFINIDAS ----
            if (provider.predefinedTemplates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Plantillas Predefinidas',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: subColor)),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) =>
                      TemplateCard(template: provider.predefinedTemplates[i]),
                  childCount: provider.predefinedTemplates.length,
                ),
              ),
            ],

            // ---- MIS PLANTILLAS ----
            if (provider.customTemplates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text('Mis Plantillas',
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: subColor)),
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

            if (provider.templates.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No hay plantillas aún.\n¡Crea tu primera meta! 🎯',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: subColor, fontSize: 15),
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateTemplateScreen()),
        ),
        backgroundColor: const Color(0xFF4CAF50),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Nueva Meta',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

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
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Tus metas de ahorro',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white54),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFF4CAF50),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (provider.predefinedTemplates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Text('Plantillas Predefinidas',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60)),
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
            if (provider.customTemplates.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: Text('Mis Plantillas',
                      style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white60)),
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
                      style: GoogleFonts.poppins(
                          color: Colors.white38, fontSize: 15),
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

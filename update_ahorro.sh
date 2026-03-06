#!/bin/bash

echo "🚀 Agregando nuevas funcionalidades a Ahorro App..."

# ============================================
# 1. THEME PROVIDER (modo claro/oscuro)
# ============================================
cat > lib/providers/theme_provider.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = true;

  bool get isDark => _isDark;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isDark = prefs.getBool('is_dark') ?? true;
    notifyListeners();
  }

  Future<void> toggle() async {
    _isDark = !_isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark', _isDark);
    notifyListeners();
  }
}
DART
echo "✅ theme_provider.dart"

# ============================================
# 2. MAIN.DART actualizado con ThemeProvider y nuevas rutas
# ============================================
cat > lib/main.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appProvider = AppProvider();
  final themeProvider = ThemeProvider();
  await appProvider.init();
  await themeProvider.init();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appProvider),
        ChangeNotifierProvider.value(value: themeProvider),
      ],
      child: const AhorroApp(),
    ),
  );
}

class AhorroApp extends StatelessWidget {
  const AhorroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Ahorro App',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,

      // ---- TEMA OSCURO ----
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF4CAF50),
          surface: Color(0xFF1A2A3A),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),

      // ---- TEMA CLARO ----
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF2E7D32),
          secondary: Color(0xFF2E7D32),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Color(0xFF1A2A3A)),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.light().textTheme),
      ),

      initialRoute: appProvider.isFirstTime ? '/onboarding' : '/home',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}
DART
echo "✅ main.dart"

# ============================================
# 3. HOME SCREEN con navegación a nuevas pantallas
# ============================================
cat > lib/screens/home_screen.dart << 'DART'
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
DART
echo "✅ home_screen.dart"

# ============================================
# 4. STATS SCREEN
# ============================================
cat > lib/screens/stats_screen.dart << 'DART'
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
DART
echo "✅ stats_screen.dart"

# ============================================
# 5. ABOUT SCREEN
# ============================================
cat > lib/screens/about_screen.dart << 'DART'
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
            Text('Ahorro App',
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
                  Text('Juan Carlos Valencia',
                      style: GoogleFonts.poppins(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Ing. en Sistemas Computacionales',
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
                  _infoRow(Icons.code_rounded, 'Desarrollado con',
                      'Flutter & Dart', textColor, subColor),
                  _divider(isDark),
                  _infoRow(Icons.savings_rounded, 'Propósito',
                      'Control de ahorro personal', textColor, subColor),
                  _divider(isDark),
                  _infoRow(Icons.calendar_today_rounded, 'Año', '2025',
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
DART
echo "✅ about_screen.dart"

# ============================================
# 6. EDIT TEMPLATE SCREEN
# ============================================
cat > lib/screens/edit_template_screen.dart << 'DART'
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
DART
echo "✅ edit_template_screen.dart"

# ============================================
# 7. APP PROVIDER con método editTemplate
# ============================================
cat > lib/providers/app_provider.dart << 'DART'
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
DART
echo "✅ app_provider.dart"

# ============================================
# 8. TEMPLATE DETAIL con botón de editar
# ============================================
cat > lib/screens/template_detail_screen.dart << 'DART'
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
DART
echo "✅ template_detail_screen.dart"

# ============================================
# 9. TEMPLATE CARD actualizada para tema claro
# ============================================
cat > lib/widgets/template_card.dart << 'DART'
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/template_model.dart';
import '../providers/theme_provider.dart';
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
    final isDark = context.watch<ThemeProvider>().isDark;
    final textColor = isDark ? Colors.white : const Color(0xFF1A2A3A);
    final subColor = isDark ? Colors.white38 : Colors.black38;
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
          color: isDark
              ? _color.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _color.withOpacity(isDark ? 0.25 : 0.2)),
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
                    style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.name,
                          style: GoogleFonts.poppins(
                              color: textColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis),
                      Text(
                        '${savingTypeLabel(t.savingType)} • ${t.entries.length} aportaciones',
                        style: GoogleFonts.poppins(
                            color: subColor, fontSize: 12),
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
                            color: subColor, fontSize: 11)),
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
                backgroundColor: _color.withOpacity(0.12),
                valueColor: AlwaysStoppedAnimation<Color>(_color),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${t.progressPercentage.toStringAsFixed(0)}% completado',
              style: GoogleFonts.poppins(color: subColor, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
DART
echo "✅ template_card.dart"

# ============================================
# 10. Agregar url_launcher al pubspec
# ============================================
cat > pubspec.yaml << 'PUBSPEC'
name: ahorro
description: App de control de ahorro personal
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  shared_preferences: ^2.2.2
  provider: ^6.1.1
  uuid: ^4.3.3
  intl: ^0.19.0
  fl_chart: ^0.68.0
  google_fonts: ^6.2.1
  flutter_animate: ^4.5.0
  url_launcher: ^6.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
  assets:
    - assets/images/
PUBSPEC
echo "✅ pubspec.yaml (url_launcher agregado)"

# ============================================
# 11. Instalar dependencias
# ============================================
echo ""
echo "📦 Instalando dependencias..."
flutter pub get

echo ""
echo "============================================"
echo "  NUEVAS FUNCIONALIDADES APLICADAS"
echo "============================================"
echo ""
echo "  ✅ Modo claro / oscuro (toggle en home)"
echo "  ✅ Pantalla de estadísticas generales"
echo "  ✅ Pantalla Acerca de (Juan Carlos Valencia)"
echo "  ✅ Editar plantilla (nombre, desc, emoji, color)"
echo "  ✅ Template cards y detail adaptados al tema"
echo ""
echo "Ejecuta: flutter run"

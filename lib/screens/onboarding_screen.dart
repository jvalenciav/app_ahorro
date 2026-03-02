import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _loading = true);
    await context.read<AppProvider>().setUserName(name);
    if (mounted) Navigator.pushReplacementNamed(context, '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom - 80,
            ),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text('💸', style: const TextStyle(fontSize: 64))
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .slideY(begin: -0.3),
                  const SizedBox(height: 24),
                  Text(
                    'Bienvenido a\nAhorro App',
                    style: GoogleFonts.poppins(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 12),
                  Text(
                    '¿Cómo te llamas?',
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.white54),
                  ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                  const SizedBox(height: 40),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      hintText: 'Tu nombre...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
                      ),
                    ),
                    onSubmitted: (_) => _submit(),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Empezar',
                              style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white)),
                    ),
                  ).animate().fadeIn(delay: 800.ms),
                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

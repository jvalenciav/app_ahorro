import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final provider = AppProvider();
  await provider.init();
  runApp(
    ChangeNotifierProvider.value(
      value: provider,
      child: const AhorroApp(),
    ),
  );
}

class AhorroApp extends StatelessWidget {
  const AhorroApp({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    return MaterialApp(
      title: 'Ahorro App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0D1B2A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF4CAF50),
          secondary: Color(0xFF4CAF50),
        ),
      ),
      initialRoute: provider.isFirstTime ? '/onboarding' : '/home',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/welcome': (_) => const WelcomeScreen(),
        '/home': (_) => const HomeScreen(),
      },
    );
  }
}

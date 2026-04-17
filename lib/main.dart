import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/models/journal_entry.dart';
// active_session.dart no longer needed for audio state
import 'features/home/screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(JournalEntryAdapter());
  
  // Open Boxes
  await Hive.openBox<JournalEntry>('journalBox');
  
  runApp(
    const ProviderScope(
      child: ArvyaxApp(),
    ),
  );
}

class ArvyaxApp extends StatelessWidget {
  const ArvyaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ArvyaX Mini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF3F6345),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F6345),
          primary: const Color(0xFF3F6345),
          surface: const Color(0xFFFFFFFF),
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: const Color(0xFF2C3E30),
          displayColor: const Color(0xFF1E2D22),
        ).copyWith(
          displayLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E2D22),
          ),
          headlineLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1E2D22),
          ),
          headlineMedium: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E2D22),
          ),
          titleLarge: GoogleFonts.outfit(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E2D22),
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}
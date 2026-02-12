import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gift_sense/gift_picker/app.dart';
import 'package:gift_sense/core/supabase_service.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 82, 33, 154),
    // brightness: Brightness.dark,
  ),
  textTheme: GoogleFonts.contentTextTheme(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseService.initialize();
  } catch (e) {
    debugPrint('main: SupabaseService.initialize failed: $e');
  }
  runApp(
    MaterialApp(
      theme: theme,
      home: const GiftPickerApp(),
    ),
  );
}

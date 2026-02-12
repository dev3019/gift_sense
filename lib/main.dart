import 'dart:developer' as developer;

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
  Object? initializationError;
  try {
    await SupabaseService.initialize();
  } catch (error, stackTrace) {
    initializationError = error;
    developer.log(
      'App initialization failed',
      name: 'main',
      error: error,
      stackTrace: stackTrace,
    );
  }

  runApp(
    MaterialApp(
      theme: theme,
      home: initializationError == null
          ? const GiftPickerApp()
          : const _InitializationErrorScreen(),
    ),
  );
}

class _InitializationErrorScreen extends StatelessWidget {
  const _InitializationErrorScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Unable to initialize the app right now. Please check your configuration and try again.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

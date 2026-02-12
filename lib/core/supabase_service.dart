import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Initializes Supabase and ensures an anonymous session exists.
///
/// Call [initialize] once at app startup before any Supabase operations.
/// The SDK persists sessions automatically, so anonymous sign-in only
/// occurs on first launch or after sign-out.
class SupabaseService {
  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    assert(
      _supabaseUrl.isNotEmpty,
      'SUPABASE_URL not set. Run with --dart-define-from-file=config/dev.json',
    );
    assert(
      _supabaseAnonKey.isNotEmpty,
      'SUPABASE_ANON_KEY not set. Run with --dart-define-from-file=config/dev.json',
    );

    try {
      await Supabase.initialize(
        url: _supabaseUrl,
        anonKey: _supabaseAnonKey,
      );
      await _ensureAnonymousSession();
    } catch (e) {
      debugPrint('SupabaseService.initialize failed: $e');
      rethrow;
    }
  }

  static Future<void> _ensureAnonymousSession() async {
    try {
      final session = client.auth.currentSession;
      if (session == null) {
        await client.auth.signInAnonymously();
      }
    } catch (e) {
      debugPrint('SupabaseService._ensureAnonymousSession failed: $e');
      rethrow;
    }
  }

  static String? get accessToken => client.auth.currentSession?.accessToken;
}


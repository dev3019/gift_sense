import 'dart:developer' as developer;

import 'package:gift_sense/gift_picker/adapters/ai/base_adapter.dart';
import 'package:gift_sense/gift_picker/adapters/providers/base_provider.dart';
import 'package:gift_sense/gift_picker/models/search.dart';
import 'package:gift_sense/gift_picker/models/gift_context.dart';
import 'package:stopwordies/stopwordies.dart';

class GiftSearchOrchestrator {
  GiftSearchOrchestrator({required this.aiAdapter, required this.providers});

  final AiAdapter aiAdapter;
  final List<BaseProvider> providers;
  late final List<String> words;

  // Singleton
  static GiftSearchOrchestrator? _instance;

  static Future<GiftSearchOrchestrator> getInstance({
    required AiAdapter aiAdapter,
    required List<BaseProvider> providers,
  }) async {
    if (_instance == null) {
      _instance = GiftSearchOrchestrator(
        aiAdapter: aiAdapter,
        providers: providers,
      );
      try {
        await _instance!.initialize();
      } catch (error, stackTrace) {
        developer.log(
          'Failed to initialize GiftSearchOrchestrator singleton',
          name: 'GiftSearchOrchestrator.getInstance',
          error: error,
          stackTrace: stackTrace,
        );
        _instance = null;
        rethrow;
      }
    }
    return _instance!;
  }

  Future<void> initialize() async {
    try {
      words = await StopWordies.getFor(locale: SWLocale.en);
    } catch (error, stackTrace) {
      developer.log(
        'Failed to load stop words',
        name: 'GiftSearchOrchestrator.initialize',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<GiftSearchResponse> search(GiftContext request) async {
    // normalize request
    final normalizedText = _normalizeText(request.description);

    // 1. Ask AI for ideas (mocked)
    List<String> ideas = [];
    try {
      ideas = await aiAdapter.getGiftIdeas(
        GiftSearchRequest(
          description: normalizedText,
          category: request.category,
          sex: request.sex,
          age: request.age,
        ),
      );
    } catch (error, stackTrace) {
      developer.log(
        'AI adapter failed to generate gift ideas',
        name: 'GiftSearchOrchestrator.search',
        error: error,
        stackTrace: stackTrace,
      );
    }

    // 2. Ask providers for links
    final items = <GiftSearchItem>[];
    if (ideas.isNotEmpty) {
      final providerResults = await Future.wait(
        providers.map((provider) async {
          try {
            return await provider.search(ideas);
          } catch (error, stackTrace) {
            developer.log(
              'Provider search failed: ${provider.name.name}',
              name: 'GiftSearchOrchestrator.search',
              error: error,
              stackTrace: stackTrace,
            );
            return <GiftSearchItem>[];
          }
        }),
      );

      for (final providerItems in providerResults) {
        items.addAll(providerItems);
      }
    }

    return GiftSearchResponse(items: items);
  }

  String _normalizeText(String text) {
    List<String> tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(' ');
    tokens.removeWhere((ele) => words.contains(ele));
    return tokens.join(' ');
  }
}

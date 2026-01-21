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
      await _instance!.initialize();
    }
    return _instance!;
  }

  Future<void> initialize() async {
    words = await StopWordies.getFor(locale: SWLocale.en);
  }

  Future<GiftSearchResponse> search(GiftContext request) async {
    // normalize request
    final normalizedText = _normalizeText(request.description);

    // 1. Ask AI for ideas (mocked)
    final ideas = await aiAdapter.getGiftIdeas(
      GiftSearchRequest(
        description: normalizedText,
        category: request.category,
        sex: request.sex,
        age: request.age,
      ),
    );

    // 2. Ask providers for links
    final items = <GiftSearchItem>[];
    if(ideas.isNotEmpty) {
      for (final provider in providers) {
        final providerItems = await provider.search(ideas);
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

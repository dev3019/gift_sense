import 'package:gift_sense/gift_picker/models/search.dart';

abstract class AiAdapter {
  Future<List<String>> getGiftIdeas(GiftSearchRequest request);
  String createPrompt(GiftSearchRequest request);
  Future<Map<String, dynamic>> callApi(String prompt);
  List<String> parseResponse(Map<String, dynamic> responseData);
}

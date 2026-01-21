import 'package:http/http.dart' as http;
import 'package:gift_sense/gift_picker/models/search.dart';

abstract class AiAdapter {
  Future<List<String>> getGiftIdeas(GiftSearchRequest request);
  String _createPrompt(GiftSearchRequest request);
  Future<http.Response> _callApi(String prompt);
  List<String> _parseResponse(http.Response response);
}

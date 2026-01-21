import 'dart:convert';

import 'package:gift_sense/gift_picker/models/search.dart';
import 'package:gift_sense/gift_picker/adapters/ai/base_adapter.dart';
import 'package:gift_sense/core/supabase_service.dart';

class GeminiAiAdapter implements AiAdapter {
  @override
  Future<List<String>> getGiftIdeas(GiftSearchRequest request) async {
    try {
      final finishedPrompt = _createPrompt(request);
      // final response = await _callApi(finishedPrompt);
      // final ideas = _parseResponse(
      //   response,
      // ).map((idea) => "${idea.trim()} ${request.category.name}").toList();
      // return ideas;
      return [
        "Tarkov USEC",
        "RDR2 Outlaws For Life",
        "Arc Raiders Graphic",
        "Tarkov BEAR Tactical",
        "RDR2 Arthur Morgan",
      ].map((ele) => "${ele.trim()} ${request.category.name}").toList();
    } catch (error) {
      // TODO: handle error
      print({'parent': 'GeminiAiAdapter.getGiftIdeas', 'error': error});
      return [];
    }
  }

  // convert request to prompt
  String _createPrompt(GiftSearchRequest request) {
    return '''You are a recommendation engine for gift ideas.

      Task:
        Generate 5 concise gift ideas.
      Rules:
        - Do NOT include explanations
        - Do NOT include numbering
        - Do NOT include links
        - Do NOT include markdown
        - each suggestion length should not exceed 30 characters
        - Output MUST be valid JSON
        - Output MUST be a JSON array of strings
      Return ONLY a JSON array of strings(the name of the gift).
      For example if it is a book return only the title & author, if it is a movie return only the title,
      if it is a song return only the title & artist, if it is a game return only the title. Something by
      which the product can be easily distinguished from other products of the same category.

      Age: ${request.age}
      Sex: ${request.sex.name}
      Category: ${request.category.name}
      Interests:
      ${request.description}''';
  }

  // make api call via Supabase edge function
  Future<Map<String, dynamic>> _callApi(String prompt) async {
    final response = await SupabaseService.client.functions.invoke(
      'gemini-proxy',
      body: {'prompt': prompt},
    );
    return response.data as Map<String, dynamic>;
  }

  // transform response to list of ideas
  List<String> _parseResponse(Map<String, dynamic> responseData) {
    if (responseData['success'] == false) return [];
    final decodedResponse = responseData['text'] as String;

    final ideas = jsonDecode(decodedResponse) as List<dynamic>;
    return ideas.map((idea) => idea.toString()).toList();
  }
}

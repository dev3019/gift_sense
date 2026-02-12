import 'dart:convert';
import 'dart:developer' as developer;

import 'package:gift_sense/gift_picker/models/search.dart';
import 'package:gift_sense/gift_picker/adapters/ai/base_adapter.dart';
import 'package:gift_sense/core/supabase_service.dart';

class GeminiAiAdapter implements AiAdapter {
  @override
  Future<List<String>> getGiftIdeas(GiftSearchRequest request) async {
    try {
      final finishedPrompt = createPrompt(request);
      if (finishedPrompt.isEmpty) return [];
      // final response = await callApi(finishedPrompt);
      // final ideas = parseResponse(
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
      developer.log(
        'Failed to build gift ideas',
        name: 'GeminiAiAdapter.getGiftIdeas',
        error: error,
      );
      return [];
    }
  }

  // convert request to prompt
  @override
  String createPrompt(GiftSearchRequest request) {
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
  @override
  Future<Map<String, dynamic>> callApi(String prompt) async {
    try {
      final response = await SupabaseService.client.functions.invoke(
        'gemini-proxy',
        body: {'prompt': prompt},
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }

      developer.log(
        'Unexpected response payload type from gemini-proxy',
        name: 'GeminiAiAdapter.callApi',
        error: data.runtimeType.toString(),
      );
      return {};
    } catch (error, stackTrace) {
      developer.log(
        'Gemini API call failed',
        name: 'GeminiAiAdapter.callApi',
        error: error,
        stackTrace: stackTrace,
      );
      return {};
    }
  }

  // transform response to list of ideas
  @override
  List<String> parseResponse(Map<String, dynamic> responseData) {
    if (responseData['success'] == false) return [];
    final text = responseData['text'];
    if (text is! String) {
      developer.log(
        'Missing or invalid text response payload',
        name: 'GeminiAiAdapter.parseResponse',
      );
      return [];
    }

    try {
      final decoded = jsonDecode(text);
      if (decoded is! List) {
        developer.log(
          'Gemini response JSON is not a list',
          name: 'GeminiAiAdapter.parseResponse',
        );
        return [];
      }

      return decoded.map((idea) => idea.toString()).toList();
    } catch (error, stackTrace) {
      developer.log(
        'Failed to parse Gemini response JSON',
        name: 'GeminiAiAdapter.parseResponse',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}

import 'dart:async';
import '../data/mock_data.dart';

/// Mock Translation Service
/// Simulates multilingual voice transcription and translation.
/// Replace the body of each method with real API calls when backend is ready.
class MockTranslationService {
  static const Duration _delay = Duration(seconds: 1);

  /// Simulates voice recognition and returns transcript in the selected language.
  static Future<Map<String, String>> recognizeVoice({
    required String languageCode,
    String craftKey = 'basket',
  }) async {
    await Future.delayed(_delay);

    final data = MockData.getVoiceTranscription(craftKey, languageCode);

    return {
      'original': data['original']!,
      'translation': data['translation']!,
      'language': languageCode,
    };
  }

  /// Simulates translation of a native language transcription to English.
  static Future<String> translateToEnglish({
    required String text,
    required String fromLanguageCode,
    String craftKey = 'basket',
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final data = MockData.getVoiceTranscription(craftKey, fromLanguageCode);

    return data['translation']!;
  }

  /// Returns the display name of a language code.
  static String getLanguageName(String code) {
    final lang = MockData.supportedLanguages.firstWhere(
      (l) => l['code'] == code,
      orElse: () => {'name': 'Unknown'},
    );
    return lang['name'] ?? 'Unknown';
  }

  // TODO: Replace with real API call
  // static Future<String> translateReal(String text, String from, String to) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/api/translate'),
  //     body: jsonEncode({'text': text, 'from': from, 'to': to}),
  //   );
  //   return jsonDecode(response.body)['translation'];
  // }
}

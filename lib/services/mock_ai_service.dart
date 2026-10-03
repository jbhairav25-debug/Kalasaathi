import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'api_config.dart';
import '../data/mock_data.dart';

/// AI service for image classification and prototype enhancement/catalogue flows.
class MockAiService {
  static const Duration _shortDelay = Duration(milliseconds: 800);
  static const Duration _mediumDelay = Duration(seconds: 1, milliseconds: 200);
  static const Set<String> _productKeys = {
    'basket', 'pot', 'saree', 'toy', 'cloth', 'default'
  };

  /// Simulates AI image enhancement with step-by-step progress callbacks.
  static Future<void> enhanceImage({
    required Function(String step, double progress) onProgress,
    required Function() onComplete,
  }) async {
    final steps = [
      ('Analyzing product...', 0.1),
      ('Detecting object...', 0.3),
      ('Removing background...', 0.55),
      ('Improving lighting...', 0.75),
      ('Optimizing image...', 0.9),
      ('Enhancement complete!', 1.0),
    ];

    for (final (step, progress) in steps) {
      await Future.delayed(_shortDelay);
      onProgress(step, progress);
    }

    await Future.delayed(_shortDelay);
    onComplete();
  }

  /// Simulates AI product analysis and catalogue generation.
  /// Returns a map with product details based on image/voice context.
  static Future<Map<String, dynamic>> generateCatalogue({
    String? productKey,
    String? imageContext,
    String? voiceContext,
  }) async {
    await Future.delayed(_mediumDelay);

    if (productKey != null && MockData.catalogueTemplates.containsKey(productKey)) {
      return MockData.catalogueTemplates[productKey]!;
    }

    // Determine template based on simple keyword matching
    String templateKey = 'default';
    final context = '${imageContext ?? ''} ${voiceContext ?? ''}'.toLowerCase();

    if (context.contains('basket') || context.contains('bamboo') || context.contains('బుట్ట')) {
      templateKey = 'basket';
    } else if (context.contains('pot') || context.contains('vase') || context.contains('terracotta') || context.contains('घड़ा') || context.contains('కుండ')) {
      templateKey = 'pot';
    } else if (context.contains('saree') || context.contains('ikat') || context.contains('pochampally') || context.contains('పట్టు') || context.contains('साड़ी')) {
      templateKey = 'saree';
    } else if (context.contains('toy') || context.contains('channapatna') || context.contains('ಆಟಿಕೆ') || context.contains('బొమ్మ')) {
      templateKey = 'toy';
    } else if (context.contains('cloth') || context.contains('fabric')) {
      templateKey = 'cloth';
    }

    return MockData.catalogueTemplates[templateKey] ?? MockData.catalogueTemplates['default']!;
  }

  /// Sends the selected image to the local classifier backend.
  static Future<Map<String, dynamic>> identifyProduct(XFile image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/ai/classify'),
    );
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await image.readAsBytes(),
        filename: image.name,
      ),
    );

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
    );
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception('Classification service returned ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic> ||
        !_productKeys.contains(decoded['product_key']) ||
        decoded['product_name'] is! String ||
        decoded['confidence'] is! num) {
      throw const FormatException('Invalid classification response');
    }
    return decoded;
  }

  /// Returns a list of mock AI processing steps for display.
  static List<String> getEnhancementSteps() {
    return [
      'Analyzing product...',
      'Detecting object...',
      'Removing background...',
      'Improving lighting...',
      'Optimizing image...',
    ];
  }

  // TODO: Replace with real API call
  // static Future<String> enhanceImageReal(File imageFile) async {
  //   final response = await http.post(
  //     Uri.parse('$baseUrl/api/enhance-image'),
  //     body: imageFile.readAsBytesSync(),
  //   );
  //   return response.body; // base64 enhanced image
  // }
}

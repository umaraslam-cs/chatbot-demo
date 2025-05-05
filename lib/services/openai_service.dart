import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey;

  OpenAIService() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key is missing. Please check your .env file.');
    }
  }

  Stream<String> getResponseStream(String userMessage) async* {
    final request = http.Request('POST', Uri.parse(_baseUrl))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      })
      ..body = jsonEncode({
        'model': 'gpt-4o',
        'stream': true,
        'messages': [
          {
            'role': 'system',
            'content': '''
You are an intelligent and friendly AI assistant for a car showroom.

Your job is to provide accurate, up-to-date answers to customer questions about various car models, including:
- Technical specifications
- Features and options
- Pricing and availability
- Comparisons between models

Base your answers only on provided car data.
'''
          },
          {'role': 'user', 'content': userMessage},
        ],
      });

    final response = await request.send();

    if (response.statusCode == 200) {
      final stream = response.stream.transform(utf8.decoder);

      await for (var line in stream) {
        for (final dataLine in line.trim().split('\n')) {
          if (dataLine.startsWith('data:')) {
            final jsonStr = dataLine.replaceFirst('data: ', '');
            if (jsonStr.trim() == '[DONE]') {
              return;
            }

            final json = jsonDecode(jsonStr);
            final content = json['choices'][0]['delta']['content'];
            if (content != null) {
              yield content;
            }
          }
        }
      }
    } else {
      throw Exception('Stream failed: ${response.statusCode} ${await response.stream.bytesToString()}');
    }
  }
}

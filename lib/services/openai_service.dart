import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/message.dart';

class OpenAIService {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  final String _apiKey;

  OpenAIService() : _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('OpenAI API key is missing. Please check your .env file.');
    }
  }

  Stream<String> getResponseStream(String userMessage, List<Message> previousMessages) async* {
    final request = http.Request('POST', Uri.parse(_baseUrl))
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      })
      ..body = jsonEncode({
        'model': 'gpt-4-turbo',
        'stream': true,
        'messages': [
          {
            "role": "system",
            "content":
                "You are an intelligent and friendly AI assistant for a car showroom.\n\nYour job is to provide accurate, up-to-date answers to customer questions about various car models, including:\n- Technical specifications\n- Features and options\n- Pricing and availability\n- Comparisons between models\n- Horsepower\n- Engine capacity (in liters)\n- Interior options\n- Engine specifications\n- 0 to 100 km/h acceleration time (e.g., '5.8 seconds')\n- And other similar technical details.\n\nBase your answers only on the provided car data. Be specific with performance metrics like 0 to 100 km/h."
          },
          // Add previous messages in reverse order (oldest first)
          ...previousMessages.reversed.map((msg) => {
                'role': msg.authorId == 'user' ? 'user' : 'assistant',
                'content': msg.text,
              }),
          {'role': 'user', 'content': userMessage},
        ],
      });

    final response = await request.send();

    if (response.statusCode == 200) {
      final stream = response.stream.transform(utf8.decoder);
      String buffer = '';

      await for (var chunk in stream) {
        buffer += chunk;

        // Process complete lines
        while (buffer.contains('\n')) {
          final lineEnd = buffer.indexOf('\n');
          final line = buffer.substring(0, lineEnd).trim();
          buffer = buffer.substring(lineEnd + 1);

          if (line.startsWith('data:')) {
            final jsonStr = line.replaceFirst('data: ', '');
            if (jsonStr.trim() == '[DONE]') {
              return;
            }

            try {
              final json = jsonDecode(jsonStr);
              final content = json['choices'][0]['delta']['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              print('Error parsing JSON: $e');
              print('Problematic JSON string: $jsonStr');
            }
          }
        }
      }

      // Process any remaining data in buffer
      if (buffer.isNotEmpty) {
        final line = buffer.trim();
        if (line.startsWith('data:')) {
          final jsonStr = line.replaceFirst('data: ', '');
          if (jsonStr.trim() != '[DONE]') {
            try {
              final json = jsonDecode(jsonStr);
              final content = json['choices'][0]['delta']['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              print('Error parsing JSON: $e');
              print('Problematic JSON string: $jsonStr');
            }
          }
        }
      }
    } else {
      throw Exception('Stream failed: ${response.statusCode} ${await response.stream.bytesToString()}');
    }
  }
}

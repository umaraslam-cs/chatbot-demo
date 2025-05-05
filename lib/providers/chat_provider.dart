import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_state.dart';
import '../models/message.dart';
import '../services/openai_service.dart';
part 'chat_provider.g.dart';

@riverpod
class ChatNotifier extends _$ChatNotifier {
  @override
  ChatState build() {
    return const ChatState();
  }

  void addMessage(Message message) {
    state = state.copyWith(
      messages: [message, ...state.messages],
    );
  }

  Future<void> sendMessage(String text) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    final userMessage = Message(
      id: '${timestamp}_user',
      text: text,
      createdAt: DateTime.now(),
      authorId: 'user',
      authorName: 'You',
    );

    final assistantMessageId = const Uuid().v4();

    final assistantMessage = Message(
      id: assistantMessageId,
      text: '...',
      createdAt: DateTime.now(),
      authorId: 'assistant',
      authorName: 'Assistant',
    );

    // Add both user and assistant placeholder
    state = state.copyWith(
      messages: [assistantMessage, userMessage, ...state.messages],
      isLoading: true,
      error: null,
    );

    try {
      final openAIService = OpenAIService();
      final stream = openAIService.getResponseStream(text);

      await for (final chunk in stream) {
        final updatedMessages = state.messages.map((msg) {
          if (msg.id == assistantMessageId) {
            // Replace the loading indicator with actual text when streaming starts
            final newText = msg.text == '...' ? chunk : msg.text + chunk;
            return msg.copyWith(text: newText);
          }
          return msg;
        }).toList();

        state = state.copyWith(messages: updatedMessages);
      }

      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('Error in chat provider: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );

      Future.delayed(const Duration(seconds: 3), () {
        state = state.copyWith(error: null);
      });
    }
  }

  void addWelcomeMessage() {
    final welcomeMessage = Message(
      id: 'welcome',
      text: 'Hello! I\'m your car showroom assistant. Ask me anything about our cars!',
      createdAt: DateTime.now(),
      authorId: 'assistant',
      authorName: 'Assistant',
    );

    state = state.copyWith(
      messages: [welcomeMessage, ...state.messages],
    );
  }
}

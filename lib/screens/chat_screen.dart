import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/chat_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatNotifierProvider.notifier).addWelcomeMessage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final chatMessages = chatState.messages.map((m) => m.toChatMessage()).toList();

    // Show error message if there is one
    if (chatState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_getUserFriendlyError(chatState.error!)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Car Showroom Assistant'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Stack(
        children: [
          Chat(
            messages: chatMessages,
            onSendPressed: (message) {
              ref.read(chatNotifierProvider.notifier).sendMessage(message.text);
            },
            user: const types.User(id: 'user'),
            theme: DefaultChatTheme(
              primaryColor: Theme.of(context).colorScheme.primary,
              secondaryColor: Theme.of(context).colorScheme.secondary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              inputBackgroundColor: Theme.of(context).colorScheme.surface,
              inputTextColor: Theme.of(context).colorScheme.onSurface,
              sendButtonIcon: Icon(Icons.send, color: Theme.of(context).colorScheme.secondary),
              receivedMessageBodyTextStyle: const TextStyle(
                color: Colors.white, // Bot message text color
              ),
              sentMessageBodyTextStyle: const TextStyle(
                color: Colors.white, // User message text color
              ),
              receivedMessageBodyLinkTextStyle: const TextStyle(
                color: Colors.blue,
              ),
              sentMessageBodyLinkTextStyle: const TextStyle(
                color: Colors.blue,
              ),
            ),
            showUserAvatars: true,
            showUserNames: true,
            customMessageBuilder: (message, {required messageWidth}) {
              if (message is types.TextMessage) {
                final textMessage = message as types.TextMessage;
                if (textMessage.author.id == 'assistant' && textMessage.text == '...') {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const ThreeDotsLoading(),
                  );
                }
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  String _getUserFriendlyError(String error) {
    if (error.contains('API key is missing')) {
      return 'Please check your API key configuration.';
    } else if (error.contains('Failed to get response')) {
      return 'Unable to connect to the server. Please try again later.';
    } else if (error.contains('Error communicating with OpenAI')) {
      return 'There was a problem processing your request. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}

class ThreeDotsLoading extends StatefulWidget {
  const ThreeDotsLoading({super.key});

  @override
  State<ThreeDotsLoading> createState() => _ThreeDotsLoadingState();
}

class _ThreeDotsLoadingState extends State<ThreeDotsLoading> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _animations = List.generate(3, (index) {
      final delay = index * 0.2;
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, delay + 0.4, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5 + (_animations[index].value * 0.5)),
                shape: BoxShape.circle,
              ),
            );
          },
        );
      }),
    );
  }
}

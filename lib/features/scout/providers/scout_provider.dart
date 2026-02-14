import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ai_scout_service.dart';

class ScoutMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ScoutMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ScoutState {
  final List<ScoutMessage> messages;
  final bool isLoading;
  final String? error;

  const ScoutState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
  });

  ScoutState copyWith({
    List<ScoutMessage>? messages,
    bool? isLoading,
    String? error,
  }) {
    return ScoutState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ScoutNotifier extends StateNotifier<ScoutState> {
  final AIScoutService _scoutService;

  ScoutNotifier(this._scoutService) : super(const ScoutState()) {
    _scoutService.initialize();
  }

  Future<void> sendMessage(String text) async {
    // Add user message
    final userMsg = ScoutMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    try {
      final response = await _scoutService.askScout(text);

      final botMsg = ScoutMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, botMsg],
        isLoading: false,
      );
    } catch (e) {
      final errorMsg = ScoutMessage(
        text: 'Sorry, I had trouble processing that. Please try again.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, errorMsg],
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final scoutProvider =
    StateNotifierProvider<ScoutNotifier, ScoutState>((ref) {
  return ScoutNotifier(AIScoutService());
});

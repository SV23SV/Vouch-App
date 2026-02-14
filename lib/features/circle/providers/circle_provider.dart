import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/circle_model.dart';

class CircleState {
  final List<CircleModel> friends;
  final List<CircleModel> pendingRequests;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  const CircleState({
    this.friends = const [],
    this.pendingRequests = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  CircleState copyWith({
    List<CircleModel>? friends,
    List<CircleModel>? pendingRequests,
    bool? isLoading,
    String? error,
    String? searchQuery,
  }) {
    return CircleState(
      friends: friends ?? this.friends,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CircleNotifier extends StateNotifier<CircleState> {
  CircleNotifier() : super(const CircleState()) {
    _loadCircle();
  }

  Future<void> _loadCircle() async {
    state = state.copyWith(isLoading: true);
    try {
      // In production, fetch from Supabase with RLS
      state = state.copyWith(
        isLoading: false,
        friends: [],
        pendingRequests: [],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    // Filter friends by name
  }

  Future<void> acceptRequest(String circleId) async {
    // Update circle status to 'active' in Supabase
  }

  Future<void> declineRequest(String circleId) async {
    // Remove the circle record
  }

  Future<void> refresh() async {
    await _loadCircle();
  }
}

final circleProvider =
    StateNotifierProvider<CircleNotifier, CircleState>((ref) {
  return CircleNotifier();
});

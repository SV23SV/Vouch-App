import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/alert_model.dart';
import '../../../core/models/vouch_model.dart';

class HomeState {
  final List<VouchModel> recentVouches;
  final List<AlertModel> activeAlerts;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.recentVouches = const [],
    this.activeAlerts = const [],
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    List<VouchModel>? recentVouches,
    List<AlertModel>? activeAlerts,
    bool? isLoading,
    String? error,
  }) {
    return HomeState(
      recentVouches: recentVouches ?? this.recentVouches,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(const HomeState()) {
    _loadData();
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true);
    try {
      // In production, this would fetch from Supabase
      // Fetching vouches from user's circle and alerts from their area
      state = state.copyWith(
        isLoading: false,
        recentVouches: [],
        activeAlerts: [],
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

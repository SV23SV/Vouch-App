import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/vouch_model.dart';
import '../../../core/services/encryption_service.dart';

class VouchState {
  final List<VouchModel> vouches;
  final bool isLoading;
  final String? error;

  const VouchState({
    this.vouches = const [],
    this.isLoading = false,
    this.error,
  });

  VouchState copyWith({
    List<VouchModel>? vouches,
    bool? isLoading,
    String? error,
  }) {
    return VouchState(
      vouches: vouches ?? this.vouches,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class VouchNotifier extends StateNotifier<VouchState> {
  final EncryptionService _encryptionService;

  VouchNotifier(this._encryptionService) : super(const VouchState());

  Future<void> createVouch({
    required String businessName,
    required String category,
    double? pricePaid,
    int safetyRating = 5,
    String? note,
    String visibilityLevel = 'circle',
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      // Encrypt price if provided
      String? encryptedPrice;
      if (pricePaid != null) {
        encryptedPrice = _encryptionService.encryptPrice(pricePaid);
      }

      final vouch = VouchModel(
        id: const Uuid().v4(),
        userId: '', // Will be set by Supabase auth
        proId: '', // Will be created or matched
        pricePaidEncrypted: encryptedPrice,
        note: note,
        safetyRating: safetyRating,
        visibilityLevel: visibilityLevel,
        createdAt: DateTime.now(),
        proName: businessName,
        proCategory: category,
      );

      // In production, this would:
      // 1. Create or find the pro in the pros table
      // 2. Insert the vouch via safeInsert (which checks for PII)
      // 3. Update the pro's average vouch score

      final updated = [...state.vouches, vouch];
      state = state.copyWith(vouches: updated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loadVouches() async {
    state = state.copyWith(isLoading: true);
    try {
      // Fetch from Supabase
      state = state.copyWith(isLoading: false, vouches: []);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final encryptionServiceProvider = Provider<EncryptionService>((ref) {
  return EncryptionService();
});

final vouchProvider =
    StateNotifierProvider<VouchNotifier, VouchState>((ref) {
  final encryption = ref.watch(encryptionServiceProvider);
  return VouchNotifier(encryption);
});

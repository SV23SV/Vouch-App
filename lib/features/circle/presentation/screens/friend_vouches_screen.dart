import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';

/// Shows all vouches from a specific friend — their "Digital Black Book."
class FriendVouchesScreen extends ConsumerWidget {
  final String friendId;

  const FriendVouchesScreen({super.key, required this.friendId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In production, fetch friend's vouches from Supabase
    return Scaffold(
      appBar: AppBar(
        title: const Text('Friend\'s Vouches'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: () => context.pop(),
        ),
      ),
      body: const EmptyState(
        icon: Icons.book_outlined,
        title: 'Digital Black Book',
        message: 'This friend hasn\'t shared any vouches yet.',
      ),
    );
  }
}

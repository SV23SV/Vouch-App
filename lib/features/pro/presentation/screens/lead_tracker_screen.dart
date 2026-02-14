import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/empty_state.dart';

/// Lead tracker showing seekers who contacted the pro.
class LeadTrackerScreen extends ConsumerWidget {
  const LeadTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lead Tracker'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: () => context.pop(),
        ),
      ),
      body: const EmptyState(
        icon: Icons.leaderboard_outlined,
        title: 'No leads yet',
        message:
            'When people tap "Call" on your profile, they\'ll appear here.',
      ),
    );
  }
}

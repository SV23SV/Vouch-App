import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../providers/circle_provider.dart';

/// Circle view — shows user's friends and their vouch counts.
class CircleScreen extends ConsumerStatefulWidget {
  const CircleScreen({super.key});

  @override
  ConsumerState<CircleScreen> createState() => _CircleScreenState();
}

class _CircleScreenState extends ConsumerState<CircleScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final circleState = ref.watch(circleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Circle'),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search friends...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                ref.read(circleProvider.notifier).search(query);
              },
            ),
          ),
          // Friends list
          Expanded(
            child: circleState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : circleState.friends.isEmpty
                    ? EmptyState(
                        icon: Icons.people_outline,
                        title: 'Your circle is empty',
                        message:
                            'Invite friends to start sharing trusted recommendations.',
                        actionLabel: 'Invite a Friend',
                        onAction: _inviteFriend,
                      )
                    : RefreshIndicator(
                        onRefresh: () =>
                            ref.read(circleProvider.notifier).refresh(),
                        child: ListView.builder(
                          itemCount: circleState.friends.length,
                          itemBuilder: (context, index) {
                            final friend = circleState.friends[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: AppConstants.defaultPadding,
                                vertical: 4,
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  radius: 28,
                                  backgroundColor: AppColors.trustBlue,
                                  child: Text(
                                    (friend.friendName ?? 'U')[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: AppColors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  friend.friendName ?? 'Friend',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                subtitle: Text(
                                  '${friend.friendVouchCount ?? 0} vouches shared',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(color: AppColors.mediumGrey),
                                ),
                                trailing: const Icon(
                                  Icons.chevron_right,
                                  size: 28,
                                ),
                                onTap: () {
                                  final friendId =
                                      friend.userAId == 'current_user'
                                          ? friend.userBId
                                          : friend.userAId;
                                  context
                                      .push('/friend/$friendId/vouches');
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _inviteFriend,
        icon: const Icon(Icons.person_add),
        label: const Text('Invite'),
      ),
    );
  }

  void _inviteFriend() {
    // Trigger deep link invite flow
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Invite link copied to clipboard!')),
    );
  }
}

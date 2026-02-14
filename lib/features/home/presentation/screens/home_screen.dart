import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/trust_card.dart';
import '../../providers/home_provider.dart';

/// Home screen / Trust Feed — the main landing screen after login.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vouch'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            iconSize: 28,
            tooltip: 'Safety Center',
            onPressed: () => context.push(AppRoutes.safetyCenter),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            iconSize: 28,
            tooltip: 'Notifications',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications coming soon')),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(homeProvider.notifier).refresh(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.scout),
                  child: Container(
                    height: AppConstants.minTouchTargetSize,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                        AppConstants.buttonBorderRadius,
                      ),
                      border: Border.all(color: AppColors.lightGrey),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: AppColors.mediumGrey),
                        const SizedBox(width: 12),
                        Text(
                          'Ask Scout to find a pro...',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.mediumGrey,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Active Alerts
              if (homeState.activeAlerts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  child: Text(
                    'Active Alerts',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    itemCount: homeState.activeAlerts.length,
                    itemBuilder: (context, index) {
                      final alert = homeState.activeAlerts[index];
                      return Container(
                        width: 280,
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber,
                              color: AppColors.error,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    alert.proName ?? 'Alert',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: AppColors.error,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    alert.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Recent Vouches
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Vouches in Your Circle',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              if (homeState.recentVouches.isEmpty)
                const EmptyState(
                  icon: Icons.handshake_outlined,
                  title: 'No vouches yet',
                  message:
                      'Invite friends to your circle and start sharing trusted recommendations.',
                  actionLabel: 'Invite a Friend',
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: homeState.recentVouches.length,
                  itemBuilder: (context, index) {
                    final vouch = homeState.recentVouches[index];
                    return TrustCard(
                      proName: vouch.proName ?? 'Service Provider',
                      category: vouch.proCategory ?? 'General',
                      voucherName: vouch.voucherName,
                      safetyRating: vouch.safetyRating,
                      onTap: () => context.push('/pro/${vouch.proId}'),
                    );
                  },
                ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addVouch),
        icon: const Icon(Icons.add),
        label: const Text('Add Vouch'),
      ),
    );
  }
}

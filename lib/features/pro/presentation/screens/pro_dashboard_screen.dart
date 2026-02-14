import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/vouch_button.dart';

/// Pro dashboard showing vouch count, verification, and lead access.
class ProDashboardScreen extends ConsumerWidget {
  const ProDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pro Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.thumb_up,
                    label: 'Total Vouches',
                    value: '0',
                    color: AppColors.trustBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    context,
                    icon: Icons.people,
                    label: 'Leads',
                    value: '0',
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Verification Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified, color: AppColors.safetyAmber),
                        const SizedBox(width: 12),
                        Text(
                          'Business Verification',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Verify your business to build trust with potential customers.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                    ),
                    const SizedBox(height: 16),
                    VouchButton(
                      label: 'Upload License Photo',
                      isOutlined: true,
                      onPressed: () {
                        // Image picker for license upload
                      },
                      icon: Icons.camera_alt,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Lead Tracker
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: const Icon(
                  Icons.leaderboard,
                  color: AppColors.trustBlue,
                  size: 36,
                ),
                title: Text(
                  'Lead Tracker',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                subtitle: Text(
                  'View and manage your leads',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                ),
                trailing: const Icon(Icons.chevron_right, size: 28),
                onTap: () => context.push(AppRoutes.leadTracker),
              ),
            ),
            const SizedBox(height: 16),

            // Subscription
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.safetyAmber),
                        const SizedBox(width: 12),
                        Text(
                          'Pro Subscription',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'First ${AppConstants.freeLeadLimit} leads are free! '
                      'Subscribe for \$${AppConstants.proSubscriptionPrice.toStringAsFixed(0)}/month '
                      'to unlock unlimited lead details.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                    ),
                    const SizedBox(height: 16),
                    VouchButton(
                      label: 'Subscribe — \$${AppConstants.proSubscriptionPrice.toStringAsFixed(0)}/mo',
                      onPressed: () {
                        // Stripe checkout flow
                      },
                      icon: Icons.credit_card,
                      backgroundColor: AppColors.safetyAmber,
                      foregroundColor: AppColors.nearBlack,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

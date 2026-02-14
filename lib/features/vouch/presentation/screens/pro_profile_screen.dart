import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/vouch_button.dart';

/// Pro profile screen with trust-tiered visibility.
/// 1st-degree: full details + price, 2nd-degree: blurred, neighborhood: aggregate.
class ProProfileScreen extends ConsumerWidget {
  final String proId;

  const ProProfileScreen({super.key, required this.proId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // In production, fetch pro details and determine trust tier
    final trustTier = AppConstants.trustTierFirstDegree;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Provider'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            iconSize: 28,
            onPressed: () {
              HapticFeedback.lightImpact();
              // Share pro profile
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Pro Header
            Container(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              color: AppColors.trustBlue.withValues(alpha: 0.05),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.trustBlue,
                    child: const Icon(Icons.business, size: 48, color: AppColors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Service Provider',
                    style: Theme.of(context).textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.trustBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Plumber',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.trustBlue,
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Trust level indicator
                  _buildTrustBadge(context, trustTier),
                ],
              ),
            ),

            // Vouch Details (visibility varies by trust tier)
            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Vouches',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),

                  if (trustTier == AppConstants.trustTierFirstDegree) ...[
                    _buildDetailCard(
                      context,
                      icon: Icons.person,
                      label: 'Vouched by',
                      value: 'Your friend Mary',
                    ),
                    _buildDetailCard(
                      context,
                      icon: Icons.attach_money,
                      label: 'Price Paid',
                      value: '\$150.00',
                    ),
                    _buildDetailCard(
                      context,
                      icon: Icons.shield,
                      label: 'Safety Rating',
                      value: '5/5',
                    ),
                    _buildDetailCard(
                      context,
                      icon: Icons.note,
                      label: 'Note',
                      value: '"Fixed our leaky faucet in 30 minutes. Very professional."',
                    ),
                  ] else if (trustTier == AppConstants.trustTierSecondDegree) ...[
                    _buildDetailCard(
                      context,
                      icon: Icons.people,
                      label: 'Vouched by',
                      value: 'A friend of Mary',
                    ),
                    _buildBlurredCard(context, 'Price Paid', '\$***'),
                    _buildDetailCard(
                      context,
                      icon: Icons.shield,
                      label: 'Safety Rating',
                      value: '5/5',
                    ),
                    const SizedBox(height: 16),
                    VouchButton(
                      label: 'Request Full Details',
                      isOutlined: true,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Access request sent!'),
                          ),
                        );
                      },
                      icon: Icons.lock_open,
                    ),
                  ] else ...[
                    _buildDetailCard(
                      context,
                      icon: Icons.groups,
                      label: 'Neighborhood',
                      value: 'Recommended by 12 neighbors',
                    ),
                    _buildDetailCard(
                      context,
                      icon: Icons.shield,
                      label: 'Average Safety',
                      value: '4.3/5',
                    ),
                  ],
                ],
              ),
            ),

            // Call button
            Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: VouchButton(
                label: 'Call Provider',
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  // Log lead and initiate call
                },
                icon: Icons.phone,
                backgroundColor: AppColors.success,
              ),
            ),

            // Report button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.largePadding,
              ),
              child: TextButton.icon(
                onPressed: () {
                  // Navigate to report form
                },
                icon: const Icon(Icons.flag, color: AppColors.error),
                label: Text(
                  'Report a problem',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustBadge(BuildContext context, int trustTier) {
    final (icon, label, color) = switch (trustTier) {
      AppConstants.trustTierFirstDegree => (
          Icons.verified,
          '1st Degree - Direct Friend',
          AppColors.firstDegree
        ),
      AppConstants.trustTierSecondDegree => (
          Icons.people,
          '2nd Degree - Friend of Friend',
          AppColors.secondDegree
        ),
      _ => (
          Icons.location_city,
          'Neighborhood',
          AppColors.neighborhood
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: AppColors.trustBlue),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurredCard(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock, size: 24, color: AppColors.mediumGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mediumGrey.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

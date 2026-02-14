import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/vouch_button.dart';
import '../../../auth/providers/auth_provider.dart';

/// User profile screen with settings and account management.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.trustBlue,
                    child: const Icon(
                      Icons.person,
                      size: 48,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authState.user?.phone ?? 'Vouch User',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Verified Member',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: AppColors.success,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Menu Items
            _buildMenuItem(
              context,
              icon: Icons.book,
              label: 'My Vouches',
              onTap: () {
                // Navigate to user's vouches
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.card_giftcard,
              label: 'Trust Bundle',
              onTap: () => context.push(AppRoutes.trustBundle),
            ),
            _buildMenuItem(
              context,
              icon: Icons.business_center,
              label: 'Pro Dashboard',
              subtitle: 'For service providers',
              onTap: () => context.push(AppRoutes.proDashboard),
            ),
            _buildMenuItem(
              context,
              icon: Icons.shield,
              label: 'Safety Center',
              onTap: () => context.push(AppRoutes.safetyCenter),
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            _buildMenuItem(
              context,
              icon: Icons.settings,
              label: 'Settings',
              onTap: () {
                // Settings screen
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                // Help screen
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.privacy_tip,
              label: 'Privacy Policy',
              onTap: () {
                // Privacy policy
              },
            ),

            const SizedBox(height: 32),

            VouchButton(
              label: 'Sign Out',
              isOutlined: true,
              onPressed: () async {
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              },
              icon: Icons.logout,
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Vouch v${AppConstants.appVersion}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        leading: Icon(icon, size: 28, color: AppColors.trustBlue),
        title: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
              )
            : null,
        trailing: const Icon(Icons.chevron_right, size: 28),
        onTap: onTap,
      ),
    );
  }
}

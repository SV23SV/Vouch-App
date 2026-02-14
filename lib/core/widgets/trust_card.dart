import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

/// A card widget that displays a vouched service provider with trust indicators.
/// Adapts display based on trust tier (1st-degree, 2nd-degree, neighborhood).
class TrustCard extends StatelessWidget {
  final String proName;
  final String category;
  final String? voucherName;
  final int trustTier;
  final int safetyRating;
  final VoidCallback? onTap;
  final String? subtitle;

  const TrustCard({
    super.key,
    required this.proName,
    required this.category,
    this.voucherName,
    this.trustTier = AppConstants.trustTierFirstDegree,
    this.safetyRating = 5,
    this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTrustIndicator(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          proName,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.mediumGrey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  _buildSafetyBadge(context),
                ],
              ),
              const SizedBox(height: 12),
              _buildVoucherInfo(context),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrustIndicator() {
    final color = switch (trustTier) {
      AppConstants.trustTierFirstDegree => AppColors.firstDegree,
      AppConstants.trustTierSecondDegree => AppColors.secondDegree,
      _ => AppColors.neighborhood,
    };

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        trustTier == AppConstants.trustTierFirstDegree
            ? Icons.verified
            : trustTier == AppConstants.trustTierSecondDegree
                ? Icons.people
                : Icons.location_city,
        color: color,
        size: 24,
      ),
    );
  }

  Widget _buildSafetyBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _safetyColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_safetyIcon, size: 16, color: _safetyColor),
          const SizedBox(width: 4),
          Text(
            '$safetyRating/5',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: _safetyColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherInfo(BuildContext context) {
    final text = switch (trustTier) {
      AppConstants.trustTierFirstDegree =>
        'Vouched by ${voucherName ?? "a friend"}',
      AppConstants.trustTierSecondDegree =>
        'Vouched by a friend of ${voucherName ?? "someone in your network"}',
      _ =>
        'Recommended by your neighborhood',
    };

    final icon = switch (trustTier) {
      AppConstants.trustTierFirstDegree => Icons.person,
      AppConstants.trustTierSecondDegree => Icons.people_outline,
      _ => Icons.groups,
    };

    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mediumGrey),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.mediumGrey,
                ),
          ),
        ),
      ],
    );
  }

  Color get _safetyColor {
    if (safetyRating >= 4) return AppColors.success;
    if (safetyRating >= 3) return AppColors.warning;
    return AppColors.error;
  }

  IconData get _safetyIcon {
    if (safetyRating >= 4) return Icons.shield;
    if (safetyRating >= 3) return Icons.shield_outlined;
    return Icons.warning_amber;
  }
}

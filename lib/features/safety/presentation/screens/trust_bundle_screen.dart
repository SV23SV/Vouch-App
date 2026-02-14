import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/vouch_button.dart';

/// Trust Bundle export screen for transferring recommendations.
class TrustBundleScreen extends ConsumerStatefulWidget {
  const TrustBundleScreen({super.key});

  @override
  ConsumerState<TrustBundleScreen> createState() => _TrustBundleScreenState();
}

class _TrustBundleScreenState extends ConsumerState<TrustBundleScreen> {
  final Set<String> _selectedPros = {};
  bool _isGenerating = false;
  String? _transferCode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Bundle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          iconSize: 28,
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transfer Your Trusted Pros',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select which providers to include in your transfer bundle. '
              'The recipient can import them with a one-time code.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.mediumGrey,
                  ),
            ),
            const SizedBox(height: 24),

            if (_transferCode != null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, size: 48, color: AppColors.success),
                    const SizedBox(height: 16),
                    Text(
                      'Transfer Code',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _transferCode!,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expires in 24 hours',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mediumGrey,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              VouchButton(
                label: 'Share Code',
                onPressed: () {
                  // Use share_plus to share
                },
                icon: Icons.share,
              ),
            ] else ...[
              Expanded(
                child: Center(
                  child: Text(
                    'No vouches to bundle yet. Add some vouches first!',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              VouchButton(
                label: 'Generate Transfer Code',
                isLoading: _isGenerating,
                onPressed: _selectedPros.isEmpty ? null : _generateCode,
                icon: Icons.qr_code,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _generateCode() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _transferCode = 'VCH-${DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase().substring(0, 6)}';
      _isGenerating = false;
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/vouch_button.dart';

/// Form for reporting a scam or safety concern.
class ReportAlertScreen extends ConsumerStatefulWidget {
  const ReportAlertScreen({super.key});

  @override
  ConsumerState<ReportAlertScreen> createState() => _ReportAlertScreenState();
}

class _ReportAlertScreenState extends ConsumerState<ReportAlertScreen> {
  final _formKey = GlobalKey<FormState>();
  final _proNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _alertType = 'scam';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _proNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a Scam'),
        backgroundColor: AppColors.error,
        leading: IconButton(
          icon: const Icon(Icons.close),
          iconSize: 28,
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your report helps protect your neighborhood. '
                        'If 3+ people report the same provider, '
                        'everyone nearby will be alerted.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Alert Type
              Text('Type of Issue', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'scam',
                    label: Text('Scam'),
                    icon: Icon(Icons.dangerous),
                  ),
                  ButtonSegment(
                    value: 'warning',
                    label: Text('Warning'),
                    icon: Icon(Icons.warning),
                  ),
                ],
                selected: {_alertType},
                onSelectionChanged: (value) {
                  setState(() => _alertType = value.first);
                },
              ),
              const SizedBox(height: 24),

              // Provider Name
              TextFormField(
                controller: _proNameController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Service Provider Name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the provider name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 500,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'What happened?',
                  hintText: 'Describe the issue in detail...',
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please describe the issue';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              VouchButton(
                label: 'Submit Report',
                isLoading: _isSubmitting,
                onPressed: _submitReport,
                icon: Icons.flag,
                backgroundColor: AppColors.error,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      // In production: insert into alerts table, check threshold
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Report submitted. Thank you for keeping the community safe.'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $e')),
        );
      }
    }
  }
}

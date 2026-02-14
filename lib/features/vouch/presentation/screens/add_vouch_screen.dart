import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/vouch_button.dart';
import '../../providers/vouch_provider.dart';

/// Form for adding a new vouch for a service provider.
class AddVouchScreen extends ConsumerStatefulWidget {
  const AddVouchScreen({super.key});

  @override
  ConsumerState<AddVouchScreen> createState() => _AddVouchScreenState();
}

class _AddVouchScreenState extends ConsumerState<AddVouchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Plumber';
  int _safetyRating = 5;
  String _visibilityLevel = AppConstants.visibilityCircle;
  bool _isSubmitting = false;

  static const _categories = [
    'Plumber',
    'Electrician',
    'Handyman',
    'Roofer',
    'Landscaper',
    'Painter',
    'HVAC',
    'Cleaning',
    'Pest Control',
    'Locksmith',
    'Auto Mechanic',
    'Moving',
    'Home Inspector',
    'General Contractor',
    'Other',
  ];

  static const _safetyEmojis = ['😟', '😐', '🙂', '😊', '🤩'];

  @override
  void dispose() {
    _businessNameController.dispose();
    _noteController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Vouch'),
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
              Text(
                'Who do you recommend?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Business Name
              TextFormField(
                controller: _businessNameController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Business or Person Name',
                  prefixIcon: Icon(Icons.business),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a business name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((cat) {
                  return DropdownMenuItem(value: cat, child: Text(cat));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedCategory = value);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Price Paid
              TextFormField(
                controller: _priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: Theme.of(context).textTheme.bodyLarge,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Price Paid (optional)',
                  prefixIcon: Icon(Icons.attach_money),
                  hintText: 'e.g., 150.00',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Price is encrypted and only visible to your direct friends.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
              ),
              const SizedBox(height: 20),

              // Safety Rating
              Text(
                'Safety Rating',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final rating = index + 1;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _safetyRating = rating);
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.shortAnimation,
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _safetyRating == rating
                            ? AppColors.trustBlue.withValues(alpha: 0.15)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _safetyRating == rating
                              ? AppColors.trustBlue
                              : AppColors.lightGrey,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _safetyEmojis[index],
                          style: const TextStyle(fontSize: 28),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Note
              TextFormField(
                controller: _noteController,
                maxLines: 3,
                maxLength: 200,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: const InputDecoration(
                  labelText: 'Quick Note (optional)',
                  hintText: 'e.g., "Fixed our leaky faucet in 30 minutes"',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 20),

              // Visibility
              Text(
                'Who can see this vouch?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              _buildVisibilityOption(
                AppConstants.visibilityCircle,
                'My Circle Only',
                'Only your direct friends',
                Icons.people,
              ),
              _buildVisibilityOption(
                AppConstants.visibilityNetwork,
                'Extended Network',
                'Friends of friends can see limited info',
                Icons.hub,
              ),
              _buildVisibilityOption(
                AppConstants.visibilityNeighborhood,
                'Neighborhood',
                'Anonymous aggregate for your area',
                Icons.location_city,
              ),
              const SizedBox(height: 32),

              // Submit
              VouchButton(
                label: 'Submit Vouch',
                isLoading: _isSubmitting,
                onPressed: _submitVouch,
                icon: Icons.check_circle,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisibilityOption(
    String value,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = _visibilityLevel == value;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _visibilityLevel = value);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.trustBlue.withValues(alpha: 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.trustBlue : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.trustBlue : AppColors.mediumGrey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? AppColors.trustBlue
                              : AppColors.nearBlack,
                        ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.mediumGrey,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.trustBlue),
          ],
        ),
      ),
    );
  }

  Future<void> _submitVouch() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      await ref.read(vouchProvider.notifier).createVouch(
            businessName: _businessNameController.text.trim(),
            category: _selectedCategory,
            pricePaid: double.tryParse(_priceController.text),
            safetyRating: _safetyRating,
            note: _noteController.text.trim(),
            visibilityLevel: _visibilityLevel,
          );

      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.white),
                SizedBox(width: 12),
                Text('Vouch added successfully!'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add vouch: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

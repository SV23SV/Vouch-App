import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/contact_service.dart';
import '../../../../core/widgets/vouch_button.dart';

/// Contact handshake screen where users sync contacts to find friends.
class ContactHandshakeScreen extends ConsumerStatefulWidget {
  const ContactHandshakeScreen({super.key});

  @override
  ConsumerState<ContactHandshakeScreen> createState() =>
      _ContactHandshakeScreenState();
}

class _ContactHandshakeScreenState
    extends ConsumerState<ContactHandshakeScreen> {
  bool _isLoading = false;
  List<Map<String, String>> _matchedFriends = [];
  bool _showResults = false;

  @override
  Widget build(BuildContext context) {
    if (_showResults) {
      return _buildRevealScreen(context);
    }
    return _buildSyncScreen(context);
  }

  Widget _buildSyncScreen(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.trustBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.contacts,
                  size: 64,
                  color: AppColors.trustBlue,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Find Your Friends',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We\'ll check if anyone in your contacts is already on Vouch. '
                'Your contacts are hashed on your device — we never see '
                'the actual phone numbers.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.mediumGrey,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppConstants.buttonBorderRadius),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, color: AppColors.success),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Privacy guarantee: Phone numbers are encrypted '
                        'on your device before anything leaves your phone.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.success,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              VouchButton(
                label: 'Sync Contacts to Find Friends',
                isLoading: _isLoading,
                onPressed: _syncContacts,
                icon: Icons.sync,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: Text(
                  'Skip for now',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRevealScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Friends Found')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_matchedFriends.isEmpty) ...[
                const SizedBox(height: 60),
                const Icon(
                  Icons.person_search,
                  size: 80,
                  color: AppColors.mediumGrey,
                ),
                const SizedBox(height: 24),
                Text(
                  'No friends found yet',
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Invite your friends to Vouch and start building your circle!',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  'Your friends are here!',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Join their circles to share trusted recommendations.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.mediumGrey,
                      ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _matchedFriends.length,
                    itemBuilder: (context, index) {
                      final friend = _matchedFriends[index];
                      return Card(
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            radius: 28,
                            backgroundColor: AppColors.trustBlue,
                            child: Text(
                              (friend['name'] ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            friend['name'] ?? 'Friend',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close),
                                iconSize: 28,
                                onPressed: () {
                                  setState(() {
                                    _matchedFriends.removeAt(index);
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.check_circle),
                                iconSize: 36,
                                color: AppColors.success,
                                onPressed: () {
                                  // Accept friend request
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${friend['name']} added to your circle!',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              VouchButton(
                label: 'Continue to Vouch',
                onPressed: () => context.go(AppRoutes.home),
                icon: Icons.arrow_forward,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncContacts() async {
    setState(() => _isLoading = true);

    try {
      final contactService = ContactService();
      final hasPermission = await contactService.requestPermission();

      if (!hasPermission) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Contact permission is needed to find friends. '
                'You can enable it in Settings.',
              ),
            ),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      // Get hashed contacts for matching
      await contactService.getHashedContacts();

      // In production, this would POST to the match-hashes edge function
      // and populate _matchedFriends from the server response
      setState(() {
        _matchedFriends = []; // Would be populated from server response
        _showResults = true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to sync contacts. Please try again.')),
        );
      }
    }
  }
}

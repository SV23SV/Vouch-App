import 'dart:async';

import 'package:app_links/app_links.dart';
// ignore: depend_on_referenced_packages
import 'package:share_plus/share_plus.dart';

/// Service for handling deep links and invite sharing.
class DeepLinkService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _subscription;

  /// Callback for when a deep link is received.
  void Function(Uri uri)? onDeepLink;

  /// Initializes deep link listening.
  Future<void> initialize() async {
    // Check initial link
    final initialLink = await _appLinks.getInitialLink();
    if (initialLink != null) {
      onDeepLink?.call(initialLink);
    }

    // Listen for incoming links
    _subscription = _appLinks.uriLinkStream.listen((uri) {
      onDeepLink?.call(uri);
    });
  }

  /// Generates an invite link for a user to share.
  String generateInviteLink({
    required String inviterId,
    String? circleContext,
  }) {
    final params = {
      'inviter': inviterId,
      if (circleContext != null) 'circle': circleContext,
      'expires': DateTime.now()
          .add(const Duration(hours: 72))
          .millisecondsSinceEpoch
          .toString(),
    };

    final queryString = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'https://vouch.app/invite?$queryString';
  }

  /// Shares an invite link via the system share sheet.
  Future<void> shareInviteLink({
    required String inviterId,
    String? message,
  }) async {
    final link = generateInviteLink(inviterId: inviterId);
    final shareText = message ??
        'Join my trusted circle on Vouch! '
            'Get recommendations from people you actually know. $link';

    await Share.share(shareText);
  }

  /// Parses invite data from a deep link URI.
  Map<String, String>? parseInviteLink(Uri uri) {
    if (uri.path != '/invite') return null;

    final inviterId = uri.queryParameters['inviter'];
    final expiresStr = uri.queryParameters['expires'];

    if (inviterId == null) return null;

    // Check expiration
    if (expiresStr != null) {
      final expires = int.tryParse(expiresStr);
      if (expires != null) {
        final expirationDate =
            DateTime.fromMillisecondsSinceEpoch(expires);
        if (DateTime.now().isAfter(expirationDate)) {
          return null; // Link expired
        }
      }
    }

    return uri.queryParameters;
  }

  void dispose() {
    _subscription?.cancel();
  }
}

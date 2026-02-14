/// Application-wide constants for the Vouch app.
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Vouch';
  static const String appVersion = '1.0.0';
  static const String appTagline = 'Trusted referrals from people you know';

  // Trust Tiers
  static const int trustTierFirstDegree = 1;
  static const int trustTierSecondDegree = 2;
  static const int trustTierNeighborhood = 3;

  // Pro Lead Limits
  static const int freeLeadLimit = 5;
  static const double proSubscriptionPrice = 99.0;

  // Invite Link Expiration
  static const Duration inviteLinkExpiration = Duration(hours: 72);

  // Safety Alert Threshold
  static const int alertThreshold = 3;
  static const double alertRadiusMiles = 5.0;

  // Contact Sync
  static const int maxContactBatchSize = 500;

  // UI Constants
  static const double minTouchTargetSize = 60.0;
  static const double defaultPadding = 16.0;
  static const double largePadding = 24.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Gemini Configuration
  static const String geminiModel = 'gemini-2.0-flash';
  static const int geminiMaxTokens = 1024;

  // Visibility Levels
  static const String visibilityCircle = 'circle';
  static const String visibilityNetwork = 'network';
  static const String visibilityNeighborhood = 'neighborhood';

  // Circle Status
  static const String circleStatusPending = 'pending';
  static const String circleStatusActive = 'active';
  static const String circleStatusBlocked = 'blocked';

  // Lead Status
  static const String leadStatusNew = 'new';
  static const String leadStatusContacted = 'contacted';
  static const String leadStatusCompleted = 'completed';
}

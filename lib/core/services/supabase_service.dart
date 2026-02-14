import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env_config.dart';
import 'privacy_service.dart';

/// Wrapper around Supabase client with built-in privacy guards.
/// Ensures no raw PII is sent in any database operations.
class SupabaseService {
  late final SupabaseClient _client;
  final PrivacyService _privacyService;

  SupabaseService({PrivacyService? privacyService})
      : _privacyService = privacyService ?? PrivacyService();

  SupabaseClient get client => _client;
  GoTrueClient get auth => _client.auth;

  /// Initializes Supabase with URL and anon key from environment config.
  Future<void> initialize() async {
    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  /// Returns the current user's ID or null.
  String? get currentUserId => _client.auth.currentUser?.id;

  /// Returns the current session.
  Session? get currentSession => _client.auth.currentSession;

  /// Whether the user is authenticated.
  bool get isAuthenticated => _client.auth.currentUser != null;

  /// Signs in with phone number using OTP.
  Future<void> signInWithPhone(String phone) async {
    await _client.auth.signInWithOtp(phone: phone);
  }

  /// Verifies OTP for phone sign-in.
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await _client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Safely inserts data after checking for PII.
  Future<List<Map<String, dynamic>>> safeInsert(
    String table,
    Map<String, dynamic> data,
  ) {
    _privacyService.inspectPayload(data);
    return _client.from(table).insert(data).select();
  }

  /// Safely updates data after checking for PII.
  Future<List<Map<String, dynamic>>> safeUpdate(
    String table,
    Map<String, dynamic> data, {
    required String column,
    required String value,
  }) {
    _privacyService.inspectPayload(data);
    return _client.from(table).update(data).eq(column, value).select();
  }

  /// Queries data from a table.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? select,
    Map<String, dynamic>? filters,
    String? orderBy,
    bool ascending = false,
    int? limit,
  }) async {
    var builder = _client.from(table).select(select ?? '*');

    PostgrestFilterBuilder filteredQuery = builder;
    if (filters != null) {
      for (final entry in filters.entries) {
        filteredQuery = filteredQuery.eq(entry.key, entry.value);
      }
    }

    PostgrestTransformBuilder transformedQuery = filteredQuery;
    if (orderBy != null) {
      transformedQuery = filteredQuery.order(orderBy, ascending: ascending);
    }

    if (limit != null) {
      transformedQuery = transformedQuery.limit(limit);
    }

    return await transformedQuery;
  }

  /// Calls a Supabase Edge Function.
  Future<FunctionResponse> callFunction(
    String functionName, {
    Map<String, dynamic>? body,
  }) async {
    if (body != null) {
      _privacyService.inspectPayload(body);
    }
    return await _client.functions.invoke(
      functionName,
      body: body,
    );
  }
}

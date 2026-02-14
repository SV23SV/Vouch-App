import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import '../config/env_config.dart';
import '../constants/app_constants.dart';
import '../models/vouch_model.dart';

/// AI Scout recommendation result.
class ScoutRecommendation {
  final String proName;
  final String proId;
  final int vouchCount;
  final String? friendRecommendation;
  final String? reason;
  final double? estimatedPrice;

  const ScoutRecommendation({
    required this.proName,
    required this.proId,
    required this.vouchCount,
    this.friendRecommendation,
    this.reason,
    this.estimatedPrice,
  });

  factory ScoutRecommendation.fromJson(Map<String, dynamic> json) {
    return ScoutRecommendation(
      proName: json['pro_name'] as String? ?? 'Unknown',
      proId: json['pro_id'] as String? ?? '',
      vouchCount: json['vouch_count'] as int? ?? 0,
      friendRecommendation: json['friend_recommendation'] as String?,
      reason: json['reason'] as String?,
      estimatedPrice: (json['estimated_price'] as num?)?.toDouble(),
    );
  }
}

/// Service for AI-powered service provider recommendations using Gemini.
class AIScoutService {
  GenerativeModel? _model;
  ChatSession? _chatSession;

  /// Initializes the Gemini model with context caching.
  void initialize() {
    _model = GenerativeModel(
      model: AppConstants.geminiModel,
      apiKey: EnvConfig.geminiApiKey,
      generationConfig: GenerationConfig(
        maxOutputTokens: AppConstants.geminiMaxTokens,
        temperature: 0.7,
      ),
      systemInstruction: Content.text(_systemPrompt),
    );
  }

  /// Starts a new chat session with neighborhood context.
  void startSession({List<VouchModel>? neighborhoodVouches}) {
    if (_model == null) {
      throw StateError('AIScoutService not initialized. Call initialize() first.');
    }

    final contextParts = <Content>[];
    if (neighborhoodVouches != null && neighborhoodVouches.isNotEmpty) {
      final context = _buildNeighborhoodContext(neighborhoodVouches);
      contextParts.add(Content.model([TextPart(context)]));
    }

    _chatSession = _model!.startChat(history: contextParts);
  }

  /// Asks the AI Scout for recommendations.
  Future<String> askScout(
    String query, {
    List<VouchModel>? userNetworkVouches,
  }) async {
    if (_chatSession == null) {
      startSession();
    }

    final enrichedQuery = _enrichQuery(query, userNetworkVouches);
    final response = await _chatSession!.sendMessage(
      Content.text(enrichedQuery),
    );

    return response.text ?? 'I could not find any recommendations for that query.';
  }

  /// Asks the AI Scout and parses structured recommendations.
  Future<List<ScoutRecommendation>> getRecommendations(
    String query, {
    List<VouchModel>? userNetworkVouches,
  }) async {
    if (_chatSession == null) {
      startSession();
    }

    final structuredQuery = '''
$query

IMPORTANT: Respond with a JSON array of recommendations. Each object should have:
- "pro_name": string
- "pro_id": string
- "vouch_count": number
- "friend_recommendation": string (who vouched for them)
- "reason": string (why they're recommended)
- "estimated_price": number or null

Respond ONLY with the JSON array, no other text.
''';

    final enrichedQuery = _enrichQuery(structuredQuery, userNetworkVouches);
    final response = await _chatSession!.sendMessage(
      Content.text(enrichedQuery),
    );

    try {
      final text = response.text ?? '[]';
      final jsonStart = text.indexOf('[');
      final jsonEnd = text.lastIndexOf(']') + 1;
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        final jsonStr = text.substring(jsonStart, jsonEnd);
        final List<dynamic> parsed = jsonDecode(jsonStr) as List<dynamic>;
        return parsed
            .map((e) =>
                ScoutRecommendation.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Fall through to empty list
    }
    return [];
  }

  String _enrichQuery(String query, List<VouchModel>? networkVouches) {
    if (networkVouches == null || networkVouches.isEmpty) {
      return query;
    }

    final buffer = StringBuffer();
    buffer.writeln('User\'s network vouches:');
    for (final vouch in networkVouches) {
      buffer.writeln(
        '- ${vouch.proName ?? "Pro"} (${vouch.proCategory ?? "unknown"}) '
        'vouched by ${vouch.voucherName ?? "a friend"}, '
        'safety: ${vouch.safetyRating}/5',
      );
    }
    buffer.writeln();
    buffer.writeln('Query: $query');
    return buffer.toString();
  }

  String _buildNeighborhoodContext(List<VouchModel> vouches) {
    final buffer = StringBuffer();
    buffer.writeln('Neighborhood context - recently vouched service providers:');
    for (final vouch in vouches) {
      buffer.writeln(
        '- ${vouch.proName ?? "Provider"} | Category: ${vouch.proCategory ?? "General"} '
        '| Safety: ${vouch.safetyRating}/5',
      );
    }
    return buffer.toString();
  }

  static const String _systemPrompt = '''
You are Vouch Scout, an AI assistant that helps users find trusted local service providers.
You have access to the user's trust network - friends and their recommendations.

Guidelines:
- Always prioritize recommendations from the user's direct circle (1st-degree connections)
- Mention which friend vouched for a provider when possible
- Be honest about the trust level of each recommendation
- If you don't have enough data, say so clearly
- Use simple, friendly language appropriate for all ages
- Keep responses concise and actionable
- Never fabricate recommendations - only use data from the user's network
- When comparing providers, highlight relevant differences (price, safety rating, who vouched)
''';
}

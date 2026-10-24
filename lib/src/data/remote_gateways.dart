import 'dart:convert';
import 'package:http/http.dart' as http;
import '../domain/models.dart';
import 'contracts.dart';

/// Token source should be implemented using FirebaseAuth.currentUser.getIdToken().
/// Never pass a customer ID or router credential from the client.
typedef TokenProvider = Future<String?> Function();

class TvApiClient {
  final Uri baseUrl;
  final TokenProvider tokenProvider;
  final http.Client httpClient;
  TvApiClient({required this.baseUrl, required this.tokenProvider, http.Client? client})
      : httpClient = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path) async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) throw StateError('Sign in required');
    final url = baseUrl.resolve(path);
    if (url.scheme != 'https' && url.host != 'localhost') {
      throw StateError('HTTPS required');
    }
    final response = await httpClient.get(url, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });
    if (response.statusCode == 401 || response.statusCode == 403) {
      throw StateError('Unauthorized or subscription access denied');
    }
    if (response.statusCode != 200) {
      throw StateError('TV service error: ${response.statusCode}');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Invalid response');
    return decoded;
  }
}

class RemoteIdentity implements IdentityGateway {
  final TvApiClient api;
  RemoteIdentity(this.api);
  @override
  Future<Customer?> currentCustomer() async {
    try {
      final json = await api.get('/v1/me');
      return Customer(
        id: json['customerId'] as String,
        displayName: (json['displayName'] ?? '') as String,
        email: (json['email'] ?? '') as String,
      );
    } on StateError {
      return null;
    }
  }
  @override
  Future<void> signOut() async => throw UnimplementedError(
    'Sign-out must be wired to the configured identity authority');
}

class RemoteSubscriptions implements SubscriptionGateway {
  final TvApiClient api;
  RemoteSubscriptions(this.api);
  @override
  Future<List<Subscription>> forCustomer(String customerId) async {
    // Backend resolves caller from verified token. Never send arbitrary customerId.
    final json = await api.get('/v1/me/subscriptions');
    final items = json['subscriptions'] as List<dynamic>? ?? [];
    return items.map((raw) {
      final item = raw as Map<String, dynamic>;
      final type = Product.values.firstWhere((p) => p.name.toUpperCase() == item['product'],
          orElse: () => throw const FormatException('Unknown product'));
      final state = SubscriptionState.values.firstWhere(
          (s) => s.name == item['status'], orElse: () => SubscriptionState.pending);
      return Subscription(
        id: item['subscriptionId'] as String, customerId: customerId,
        plan: (item['plan'] ?? '') as String, product: type, state: state);
    }).toList(growable: false);
  }
}

class RemoteTvCatalog implements TvCatalogGateway {
  final TvApiClient api;
  RemoteTvCatalog(this.api);
  @override
  Future<List<TvChannel>> channels() async {
    final response = await api.get('/v1/tv/guide');
    final items = response['channels'] as List<dynamic>? ?? [];
    return items.map((raw) {
      final json = raw as Map<String, dynamic>;
      // Stream URL intentionally omitted: require separate entitlement-checked
      // signed playback endpoint before exposing any licensed media.
      return TvChannel(
        id: json['id'] as String, title: json['name'] as String,
        category: (json['category'] ?? '') as String,
        description: (json['synopsis'] ?? '') as String,
        number: (json['number'] as num).toInt(),
        replayAllowed: json['replayAllowed'] == true);
    }).toList(growable: false);
  }
  @override
  Future<List<Programme>> schedule(String channelId) async {
    final response = await api.get('/v1/tv/channels/${Uri.encodeComponent(channelId)}/schedule');
    final items = response['programmes'] as List<dynamic>? ?? [];
    return items.map((raw) {
      final json = raw as Map<String, dynamic>;
      return Programme(
        id: json['id'] as String, channelId: channelId,
        title: json['title'] as String, synopsis: (json['synopsis'] ?? '') as String,
        beginsAt: DateTime.parse(json['startsAt'] as String),
        endsAt: DateTime.parse(json['endsAt'] as String));
    }).toList(growable: false);
  }
}

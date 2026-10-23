import '../domain/models.dart';
import 'contracts.dart';

class DemoIdentity implements IdentityGateway {
  @override
  Future<Customer?> currentCustomer() async => const Customer(id: 'demo-customer', displayName: 'Demo Viewer', email: 'demo@example.invalid');
  @override
  Future<void> signOut() async {}
}

class DemoSubscriptions implements SubscriptionGateway {
  @override
  Future<List<Subscription>> forCustomer(String customerId) async => [
    Subscription(id: 'demo-tv', customerId: customerId, plan: 'Preview', product: Product.tv, state: SubscriptionState.active),
  ];
}

class DemoTvCatalog implements TvCatalogGateway {
  static final items = <TvChannel>[
    TvChannel(id: 'test', title: 'Video Test Channel', category: 'Demo', description: 'Public sample footage; not a live licensed TV broadcaster.', number: 101, hlsUrl: Uri.parse('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8')),
    const TvChannel(id: 'techruptive', title: 'Techruptive', category: 'Technology', description: 'Authorized broadcast feed pending.', number: 201),
    const TvChannel(id: 'education', title: 'Education', category: 'Learning', description: 'Partner feed pending.', number: 301),
    const TvChannel(id: 'community', title: 'Community & Faith', category: 'Community', description: 'Partner feed pending.', number: 401),
  ];
  @override
  Future<List<TvChannel>> channels() async => List.unmodifiable(items);
  @override
  Future<List<Programme>> schedule(String channelId) async => const [];
}

class DemoAudience implements AudienceGateway {
  ViewerConsent value = const ViewerConsent();
  @override
  Future<ViewerConsent> consent(String customerId) async => value;
  @override
  Future<void> saveConsent(String customerId, ViewerConsent consent) async { value = consent; }
}

class DemoIsp implements IspGateway {
  @override
  Future<Map<String, dynamic>> serviceSummary(String customerId) async => {'status': 'not_connected'};
}

class DemoWorkspace implements WorkspaceGateway {
  @override
  Future<Uri?> dashboardUrl(String customerId) async => null;
}

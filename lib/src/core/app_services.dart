import '../data/contracts.dart';
import '../data/demo_gateways.dart';

class AppServices {
  final IdentityGateway identity;
  final SubscriptionGateway subscriptions;
  final TvCatalogGateway catalog;
  final AudienceGateway audience;
  final IspGateway isp;
  final WorkspaceGateway workspace;

  const AppServices({required this.identity, required this.subscriptions, required this.catalog, required this.audience, required this.isp, required this.workspace});

  factory AppServices.demo() => AppServices(
    identity: DemoIdentity(),
    subscriptions: DemoSubscriptions(),
    catalog: DemoTvCatalog(),
    audience: DemoAudience(),
    isp: DemoIsp(),
    workspace: DemoWorkspace(),
  );
}

import '../domain/models.dart';

/// Production implementations must validate Firebase identity on the backend.
/// These interfaces deliberately do not read other products' databases directly.
abstract class IdentityGateway {
  Future<Customer?> currentCustomer();
  Future<void> signOut();
}

abstract class SubscriptionGateway {
  Future<List<Subscription>> forCustomer(String customerId);
}

abstract class TvCatalogGateway {
  Future<List<TvChannel>> channels();
  Future<List<Programme>> schedule(String channelId);
}

abstract class AudienceGateway {
  Future<ViewerConsent> consent(String customerId);
  Future<void> saveConsent(String customerId, ViewerConsent consent);
}

/// ISP and Workspace are integrated through server-authorized APIs only.
abstract class IspGateway {
  Future<Map<String, dynamic>> serviceSummary(String customerId);
}

abstract class WorkspaceGateway {
  Future<Uri?> dashboardUrl(String customerId);
}

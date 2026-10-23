enum Product { tv, isp, workspace }
enum SubscriptionState { pending, active, paused, expired }

class Customer {
  final String id, displayName, email;
  final Set<String> roles;
  const Customer({required this.id, required this.displayName, required this.email, this.roles = const {'subscriber'}});
}

class Subscription {
  final String id, customerId, plan;
  final Product product;
  final SubscriptionState state;
  const Subscription({required this.id, required this.customerId, required this.plan, required this.product, required this.state});
  bool get active => state == SubscriptionState.active;
}

class TvChannel {
  final String id, title, category, description;
  final int number;
  final Uri? hlsUrl;
  final bool replayAllowed;
  const TvChannel({required this.id, required this.title, required this.category, required this.description, required this.number, this.hlsUrl, this.replayAllowed = false});
}

class Programme {
  final String id, channelId, title, synopsis;
  final DateTime beginsAt, endsAt;
  const Programme({required this.id, required this.channelId, required this.title, required this.synopsis, required this.beginsAt, required this.endsAt});
}

class ViewerConsent {
  final bool recommendations, marketing;
  const ViewerConsent({this.recommendations = false, this.marketing = false});
  ViewerConsent copyWith({bool? recommendations, bool? marketing}) => ViewerConsent(recommendations: recommendations ?? this.recommendations, marketing: marketing ?? this.marketing);
}

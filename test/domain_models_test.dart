import 'package:flutter_test/flutter_test.dart';
import 'package:tekntandao_tv/src/domain/models.dart';
import 'package:tekntandao_tv/src/data/demo_gateways.dart';

void main() {
  test('subscription status is explicit', () {
    const pending = Subscription(id: 'one', customerId: 'c', plan: 'Basic', product: Product.tv, state: SubscriptionState.pending);
    expect(pending.active, isFalse);
  });

  test('demo guide uses stable unique channel positions', () async {
    final channels = await DemoTvCatalog().channels();
    expect(channels.map((c) => c.number).toSet().length, channels.length);
    expect(channels.any((c) => c.number == 201), isTrue);
  });

  test('marketing consent defaults to opt-out', () {
    const consent = ViewerConsent();
    expect(consent.marketing, isFalse);
    expect(consent.recommendations, isFalse);
  });
}

import 'package:flutter/material.dart';

/// Visual package selector. Billing and network provisioning are deliberately
/// not performed in this screen; these must use the verified shared backend.
class BundlePlansScreen extends StatelessWidget {
  const BundlePlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const packages = [
      (name: 'TV', subtitle: 'Watch licensed channels across eligible devices',
       icon: Icons.tv, product: 'TV'),
      (name: 'Internet', subtitle: 'Manage your home internet subscription',
       icon: Icons.wifi, product: 'ISP'),
      (name: 'Internet + TV', subtitle: 'One subscription, both services, one customer account',
       icon: Icons.all_inclusive, product: 'ISP_TV_BUNDLE'),
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('TeknTandao packages')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text('Choose how you connect and watch', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        const Text('Standalone services or one bundled subscription. '
            'Plans and prices will appear after billing and service-area configuration.'),
        const SizedBox(height: 20),
        for (final plan in packages)
          Card(child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: ListTile(
            leading: Icon(plan.icon, size: 30),
            title: Text(plan.name),
            subtitle: Text(plan.subtitle),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
              title: Text(plan.name),
              content: Text('Product code: ${plan.product}\n\n'
                'This is a package preview. Checkout will become available after '
                'the account, service-area and verified payment integrations are configured.'),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
            )),
          ))),
        const SizedBox(height: 12),
        const Text('Existing standalone subscriptions remain active until the customer '
          'approves a switch. A bundle must never create duplicate charges.'),
      ]),
    );
  }
}

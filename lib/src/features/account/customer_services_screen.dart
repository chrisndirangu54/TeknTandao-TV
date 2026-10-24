import 'package:flutter/material.dart';
import '../../core/app_services.dart';
import '../../domain/models.dart';

/// Customer hub for standalone TV, ISP and bundled services.
/// A real deployment injects authenticated gateway implementations.
class CustomerServicesScreen extends StatefulWidget {
  final AppServices services;
  const CustomerServicesScreen({super.key, required this.services});
  @override
  State<CustomerServicesScreen> createState() => _CustomerServicesScreenState();
}

class _CustomerServicesScreenState extends State<CustomerServicesScreen> {
  bool busy = true;
  String? error;
  Customer? customer;
  List<Subscription> subscriptions = const [];
  Map<String, dynamic> isp = const {};
  Uri? workspaceUrl;

  @override
  void initState() { super.initState(); refresh(); }

  Future<void> refresh() async {
    setState(() { busy = true; error = null; });
    try {
      final person = await widget.services.identity.currentCustomer();
      if (person == null) {
        if (mounted) setState(() { busy = false; error = 'Sign in to see your services.'; });
        return;
      }
      final subs = await widget.services.subscriptions.forCustomer(person.id);
      final connection = await widget.services.isp.serviceSummary(person.id);
      final workspace = await widget.services.workspace.dashboardUrl(person.id);
      if (!mounted) return;
      setState(() {
        customer = person; subscriptions = subs; isp = connection;
        workspaceUrl = workspace; busy = false;
      });
    } catch (_) {
      if (mounted) setState(() { busy = false; error = 'Could not load services. Please retry.'; });
    }
  }

  Widget serviceTile(IconData icon, String title, String description, bool subscribed) {
    return Card(child: ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(description),
      trailing: Chip(label: Text(subscribed ? 'Active' : 'Not active')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final entitled = subscriptions.where((s) => s.active).map((s) => s.product).toSet();
    final hasTv = entitled.contains(Product.tv) || entitled.contains(Product.ispTvBundle);
    final hasIsp = entitled.contains(Product.isp) || entitled.contains(Product.ispTvBundle);
    return Scaffold(
      appBar: AppBar(title: const Text('My TeknTandao'), actions: [
        IconButton(onPressed: refresh, tooltip: 'Refresh services', icon: const Icon(Icons.refresh)),
      ]),
      body: busy ? const Center(child: CircularProgressIndicator()) :
        error != null ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(error!), FilledButton(onPressed: refresh, child: const Text('Retry')),
        ])) : ListView(padding: const EdgeInsets.all(20), children: [
          Text('Welcome, ${customer?.displayName ?? ''}', style: Theme.of(context).textTheme.headlineSmall),
          Text('Customer ID: ${customer?.id ?? 'Unknown'}'),
          const SizedBox(height: 16),
          serviceTile(Icons.tv, 'Television', 'Live channels and programme access', hasTv),
          serviceTile(Icons.wifi, 'Home internet', 'Connection and customer support', hasIsp),
          Card(child: ListTile(
            leading: const Icon(Icons.dashboard_customize_outlined),
            title: const Text('TeknTandao Workspace'),
            subtitle: Text(workspaceUrl == null
              ? 'Central workspace connection not configured'
              : 'Workspace account linked; external navigation not configured'),
            trailing: const Icon(Icons.lock_outline),
          )),
          const SizedBox(height: 16),
          Text('Internet status: ${isp['status'] ?? 'Not connected'}'),
          const SizedBox(height: 10),
          Text('Subscriptions', style: Theme.of(context).textTheme.titleLarge),
          if (subscriptions.isEmpty) const Text('No subscriptions found.'),
          for (final sub in subscriptions) ListTile(
            title: Text('${sub.product.name.toUpperCase()} · ${sub.plan}'),
            subtitle: Text('Status: ${sub.state.name}'),
            leading: const Icon(Icons.receipt_long_outlined),
          ),
          const SizedBox(height: 16),
          const Text('Service activation, payments, technical diagnostics and account '
              'migration require verified production integrations.'),
        ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/app_services.dart';
import '../../domain/models.dart';
import '../bundles/bundle_plans_screen.dart';
import '../account/customer_services_screen.dart';

class TvScreen extends StatefulWidget {
  final AppServices services;
  const TvScreen({super.key, required this.services});
  @override
  State<TvScreen> createState() => _TvScreenState();
}

class _TvScreenState extends State<TvScreen> {
  List<TvChannel> channels = [];
  TvChannel? selected;
  VideoPlayerController? player;
  String filter = '';
  bool loading = true;
  bool smartPicks = false;
  bool marketingConsent = false;
  String? error;
  int requestVersion = 0;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final result = await widget.services.catalog.channels();
      if (!mounted) return;
      result.sort((a, b) => a.number.compareTo(b.number));
      setState(() { channels = result; loading = false; });
      if (result.isNotEmpty) await _switchTo(result.first);
    } catch (_) {
      if (mounted) setState(() { loading = false; error = 'Could not load channel catalogue.'; });
    }
  }

  Future<void> _switchTo(TvChannel channel) async {
    final version = ++requestVersion;
    final previous = player;
    setState(() { selected = channel; player = null; loading = channel.hlsUrl != null; error = null; });
    await previous?.dispose();
    if (!mounted || version != requestVersion || channel.hlsUrl == null) return;
    final next = VideoPlayerController.networkUrl(channel.hlsUrl!);
    try {
      await next.initialize();
      if (!mounted || version != requestVersion) { await next.dispose(); return; }
      await next.setLooping(true); // sample VOD only; production live streams must not loop
      await next.play();
      if (!mounted || version != requestVersion) { await next.dispose(); return; }
      setState(() { player = next; loading = false; });
    } catch (_) {
      await next.dispose();
      if (mounted && version == requestVersion) setState(() { loading = false; error = 'Playback unavailable; verify network and codec support.'; });
    }
  }

  @override
  void dispose() {
    requestVersion++;
    player?.dispose();
    super.dispose();
  }

  Future<void> _privacy() async {
    final customer = await widget.services.identity.currentCustomer();
    if (customer == null) return;
    final saved = await widget.services.audience.consent(customer.id);
    if (!mounted) return;
    setState(() { smartPicks = saved.recommendations; marketingConsent = saved.marketing; });
    showModalBottomSheet<void>(context: context, builder: (sheetContext) => StatefulBuilder(builder: (context, setSheetState) =>
      SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Audience privacy', style: TextStyle(fontSize: 20)),
        SwitchListTile(title: const Text('Optional recommendations'), value: smartPicks, onChanged: (v) { setSheetState(() => smartPicks = v); setState(() {}); }),
        SwitchListTile(title: const Text('Marketing notifications'), value: marketingConsent, onChanged: (v) { setSheetState(() => marketingConsent = v); setState(() {}); }),
        FilledButton(onPressed: () async {
          await widget.services.audience.saveConsent(customer.id, ViewerConsent(recommendations: smartPicks, marketing: marketingConsent));
          if (sheetContext.mounted) Navigator.pop(sheetContext);
        }, child: const Text('Save preferences')),
      ])))));
  }

  @override
  Widget build(BuildContext context) {
    final visible = channels.where((c) => ('${c.number} ${c.title} ${c.category}').toLowerCase().contains(filter.toLowerCase())).toList();
    final scheme = Theme.of(context).colorScheme;
    final video = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: Colors.black, child: Center(
        child: loading ? const CircularProgressIndicator() : error != null ? Text(error!, textAlign: TextAlign.center) :
          player != null && player!.value.isInitialized ? AspectRatio(aspectRatio: player!.value.aspectRatio, child: VideoPlayer(player!)) :
          const Text('No authorized stream configured', textAlign: TextAlign.center),
      ))),
      const SizedBox(height: 12),
      Text(selected == null ? 'Select a channel' : 'CH ${selected!.number} · ${selected!.title}', style: Theme.of(context).textTheme.titleLarge),
      Text(selected?.description ?? 'Broadcaster-first television'),
      if (player != null) Row(children: [
        IconButton(tooltip: 'Play or pause', onPressed: () => setState(() => player!.value.isPlaying ? player!.pause() : player!.play()),
          icon: Icon(player!.value.isPlaying ? Icons.pause : Icons.play_arrow)),
        const Text('Sample video'),
      ]),
      const SizedBox(height: 16),
      Text('Discover', style: Theme.of(context).textTheme.titleLarge),
      Text(smartPicks ? 'Recommendation preferences enabled; AI service not yet configured.' : 'Optional recommendations are off. All listed channels remain discoverable.'),
      TextButton.icon(onPressed: _privacy, icon: const Icon(Icons.privacy_tip_outlined), label: const Text('Privacy and preferences')),
    ]);
    final guide = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Live TV guide', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), border: OutlineInputBorder(), hintText: 'Find channel or category'),
        onChanged: (value) => setState(() => filter = value)),
      const SizedBox(height: 8),
      for (final channel in visible) Card(child: ListTile(
        selected: channel.id == selected?.id,
        selectedTileColor: scheme.surfaceContainerHighest,
        leading: CircleAvatar(child: Text('${channel.number}')),
        title: Text(channel.title),
        subtitle: Text('${channel.category} · ${channel.hlsUrl == null ? "Awaiting broadcaster" : "Sample video"}'),
        onTap: () => _switchTo(channel),
      )),
      if (visible.isEmpty) const Text('No channels match your search.'),
    ]);
    return Scaffold(
      appBar: AppBar(title: const Text('TeknTandao TV'), actions: [
        IconButton(tooltip: 'My TV and internet services', icon: const Icon(Icons.manage_accounts_outlined),
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => CustomerServicesScreen(services: widget.services)))),
        IconButton(tooltip: 'TV and Internet packages', icon: const Icon(Icons.wifi_tethering),
          onPressed: () => Navigator.push(context, MaterialPageRoute<void>(builder: (_) => const BundlePlansScreen()))),
        IconButton(tooltip: 'Account', onPressed: () => showDialog<void>(context: context, builder: (ctx) =>
          AlertDialog(title: const Text('Account integration'),
            content: const Text('Firebase single sign-on and subscriber entitlements require your configuration. This demo does not authenticate real subscribers.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))])),
          icon: const Icon(Icons.account_circle_outlined)),
      ]),
      body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth >= 780) {
          return Padding(padding: const EdgeInsets.all(20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(flex: 5, child: SingleChildScrollView(child: video)),
            const SizedBox(width: 20),
            Expanded(flex: 4, child: ListView(children: [guide])),
          ]));
        }
        return ListView(padding: const EdgeInsets.all(16), children: [video, const Divider(), guide]);
      })),
    );
  }
}

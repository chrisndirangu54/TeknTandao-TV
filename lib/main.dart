import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(const TeknTandaoTV());

class Channel {
  final int number;
  final String name;
  final String category;
  final String description;
  final String? streamUrl;
  const Channel(this.number, this.name, this.category, this.description, this.streamUrl);
}

// Only the first item is a public test stream. Other channels are placeholders
// until the broadcaster provides a licensed HLS feed and schedule.
const channels = <Channel>[
  Channel(101, 'Streaming Test Channel', 'Demo', 'Public HLS test stream for player validation.', 'https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
  Channel(201, 'Techruptive', 'Technology', 'Awaiting an authorized broadcaster stream.', null),
  Channel(301, 'Education', 'Learning', 'Awaiting an authorized educational partner.', null),
  Channel(401, 'Community & Faith', 'Community', 'Awaiting an authorized broadcaster stream.', null),
];

class TeknTandaoTV extends StatelessWidget {
  const TeknTandaoTV({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'TeknTandao TV',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF205A91), brightness: Brightness.dark), useMaterial3: true),
    home: const TVHome(),
  );
}

class TVHome extends StatefulWidget {
  const TVHome({super.key});
  @override
  State<TVHome> createState() => _TVHomeState();
}

class _TVHomeState extends State<TVHome> {
  Channel selected = channels.first;
  VideoPlayerController? controller;
  bool loading = false;
  String? playbackError;
  String query = '';
  bool showSmartPicks = true;

  @override
  void initState() {
    super.initState();
    _select(channels.first);
  }

  Future<void> _select(Channel channel) async {
    final old = controller;
    setState(() {
      selected = channel;
      controller = null;
      playbackError = null;
      loading = channel.streamUrl != null;
    });
    await old?.dispose();
    if (channel.streamUrl == null || !mounted) return;
    final player = VideoPlayerController.networkUrl(Uri.parse(channel.streamUrl!));
    try {
      await player.initialize();
      if (!mounted || selected != channel) {
        await player.dispose();
        return;
      }
      player.setLooping(true);
      await player.play();
      setState(() { controller = player; loading = false; });
    } catch (_) {
      await player.dispose();
      if (mounted && selected == channel) setState(() {
        loading = false;
        playbackError = 'Stream unavailable on this device or network.';
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final matches = channels.where((c) => '${c.number} ${c.name} ${c.category}'.toLowerCase().contains(query.toLowerCase())).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('TeknTandao TV'), actions: [
        IconButton(
          tooltip: 'About account integration',
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () => showDialog<void>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('TeknTandao account'),
            content: const Text('Unified sign-in and subscriptions are planned; no authentication backend has been connected in this prototype.'),
            actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))],
          )),
        ),
      ]),
      body: SafeArea(child: LayoutBuilder(builder: (context, limits) {
        final wide = limits.maxWidth >= 760;
        final player = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          AspectRatio(aspectRatio: 16 / 9, child: ColoredBox(color: Colors.black, child: Center(
            child: loading ? const CircularProgressIndicator() :
              playbackError != null ? Text(playbackError!, textAlign: TextAlign.center) :
              controller != null && controller!.value.isInitialized
                ? AspectRatio(aspectRatio: controller!.value.aspectRatio, child: VideoPlayer(controller!))
                : const Text('No authorized stream connected', textAlign: TextAlign.center),
          ))),
          const SizedBox(height: 12),
          Text('CH ${selected.number} · ${selected.name}', style: Theme.of(context).textTheme.titleLarge),
          Text(selected.description),
          const SizedBox(height: 8),
          if (controller != null) Row(children: [
            IconButton(tooltip: 'Play or pause', icon: Icon(controller!.value.isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () => setState(() { controller!.value.isPlaying ? controller!.pause() : controller!.play(); })),
            const Text('Demo stream — playback controls only'),
          ]),
          const SizedBox(height: 12),
          SwitchListTile.adaptive(title: const Text('Optional Smart Picks'), subtitle: const Text('Channel listings stay visible regardless of recommendations'),
            value: showSmartPicks, onChanged: (v) => setState(() => showSmartPicks = v)),
          if (showSmartPicks) const Padding(padding: EdgeInsets.all(8), child: Text('Discover: education · technology · community (AI recommendations not connected yet)')),
        ]);
        final guide = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Channel guide', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          TextField(decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Find a channel or category', border: OutlineInputBorder()),
            onChanged: (v) => setState(() => query = v)),
          const SizedBox(height: 8),
          ...matches.map((c) => Card(child: ListTile(
            selected: selected == c,
            leading: CircleAvatar(child: Text('${c.number}')),
            title: Text(c.name),
            subtitle: Text('${c.category} · ${c.streamUrl == null ? "Coming soon" : "Test video"}'),
            onTap: () => _select(c),
          ))),
          if (matches.isEmpty) const Padding(padding: EdgeInsets.all(16), child: Text('No matching channels.')),
        ]);
        if (wide) return Padding(padding: const EdgeInsets.all(20), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 5, child: SingleChildScrollView(child: player)),
          const SizedBox(width: 20),
          Expanded(flex: 4, child: SingleChildScrollView(child: guide)),
        ]));
        return ListView(padding: const EdgeInsets.all(14), children: [player, const Divider(), guide]);
      })),
    );
  }
}

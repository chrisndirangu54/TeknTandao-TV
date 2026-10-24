import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'tv_library.dart';
import 'tv_discovery.dart';
import 'tv_media_controls.dart';
import 'tv_profile_settings.dart';
import 'playback_diagnostics.dart';
import '../../core/app_services.dart';
import '../../domain/models.dart';

/// 10-foot interface designed for D-pad/Select/Back rather than touchscreen.
class AndroidTvHome extends StatefulWidget {
  final AppServices services;
  const AndroidTvHome({super.key, required this.services});
  @override
  State<AndroidTvHome> createState() => _AndroidTvHomeState();
}

class _AndroidTvHomeState extends State<AndroidTvHome> {
  List<TvChannel> channels = const [];
  int selectedIndex = 0;
  VideoPlayerController? player;
  String? error;
  List<Programme> programmeGuide = const [];
  bool loading = true;
  int generation = 0;
  final FocusNode guideFocus = FocusNode(debugLabel: 'Guide');
  final ScrollController scroll = ScrollController();
  final TvLibrary library = TvLibrary();
  DateTime playbackStartedAt = DateTime.now();
  bool diagnosticsVisible = false;

  @override
  void initState() {
    super.initState();
    library.load().then((_) { if (mounted) setState(() {}); });
    load();
  }

  Future<void> load() async {
    try {
      final values = await widget.services.catalog.channels();
      if (!mounted) return;
      values.sort((a,b) => a.number.compareTo(b.number));
      setState(() { channels = values; loading = false; });
      if (values.isNotEmpty) await tune(0);
    } catch (_) {
      if (mounted) setState(() { error = 'Channel guide unavailable'; loading = false; });
    }
  }

  Future<void> tune(int index) async {
    if (index < 0 || index >= channels.length) return;
    final request = ++generation;
    playbackStartedAt = DateTime.now();
    final old = player;
    setState(() { selectedIndex = index; player = null; error = null; programmeGuide = const []; });
    widget.services.catalog.schedule(channels[index].id).then((items) {
      if (mounted && generation == request) setState(() => programmeGuide = items);
    }).catchError((Object _) => <Programme>[]);
    await old?.dispose();
    if (!mounted || generation != request) return;
    final url = channels[index].hlsUrl;
    if (url == null) return;
    final next = VideoPlayerController.networkUrl(url);
    try {
      await next.initialize();
      if (!mounted || generation != request) { await next.dispose(); return; }
      await next.play();
      if (!mounted || generation != request) { await next.dispose(); return; }
      setState(() => player = next);
      library.recordProgress(channels[index].id, next.value.position);
    library.save();
    } catch (_) {
      await next.dispose();
      if (mounted && generation == request) setState(() => error = 'Playback unavailable on this device.');
    }
  }

  void move(int offset) {
    if (channels.isEmpty) return;
    final index = (selectedIndex + offset).clamp(0, channels.length - 1);
    if (index != selectedIndex) tune(index);
  }

  void openDiscovery() {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => TvDiscoveryScreen(
      channels: channels, library: library, onSelect: (channel) {
        Navigator.pop(context);
        final i = channels.indexWhere((c) => c.id == channel.id);
        if (i >= 0) tune(i);
      },
    ))).then((_) { if (mounted) guideFocus.requestFocus(); });
  }

  @override
  void dispose() {
    generation++;
    guideFocus.dispose();
    scroll.dispose();
    player?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = channels.isEmpty ? null : channels[selectedIndex];
    return Scaffold(
      backgroundColor: const Color(0xFF0A1221),
      body: SafeArea(child: Padding(
        padding: const EdgeInsets.all(34),
        child: Focus(
          autofocus: true,
          focusNode: guideFocus,
          onKeyEvent: (node, event) {
            if (event is! KeyDownEvent) return KeyEventResult.ignored;
            if (event.logicalKey == LogicalKeyboardKey.keyF) {
              openDiscovery(); return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              move(1); return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              move(-1); return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.select ||
                event.logicalKey == LogicalKeyboardKey.enter) {
              if (channels.isNotEmpty) tune(selectedIndex);
              return KeyEventResult.handled;
            }
            if (event.logicalKey == LogicalKeyboardKey.mediaPlayPause &&
                player != null) {
              setState(() { player!.value.isPlaying ? player!.pause() : player!.play(); });
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.tv, color: Colors.lightBlueAccent, size: 34),
              const SizedBox(width: 16),
              Text('TeknTandao TV', style: Theme.of(context).textTheme.headlineMedium),
              const Spacer(),
              TextButton.icon(onPressed: openDiscovery, icon: const Icon(Icons.search),
                label: const Text('Search')),
              IconButton(tooltip:'Preferences',icon:const Icon(Icons.settings),onPressed:(){
                Navigator.push(context,MaterialPageRoute<void>(builder:(_)=>TvProfileSettings(library:library)))
                  .then((_){if(mounted){setState((){});guideFocus.requestFocus();}});
              }),
              IconButton(tooltip:'Playback diagnostics',icon:const Icon(Icons.monitor_heart_outlined),
                onPressed:()=>setState(()=>diagnosticsVisible=!diagnosticsVisible)),
              const Text('TV Guide  •  D-pad ↑↓ to change channels',
                style: TextStyle(color: Colors.white70)),
            ]),
            const SizedBox(height: 26),
            Expanded(child: Row(children: [
              Expanded(flex: 7, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                AspectRatio(aspectRatio: 16/9, child: ColoredBox(
                  color: Colors.black,
                  child: Center(child: loading
                    ? const CircularProgressIndicator()
                    : error != null ? Text(error!)
                    : player != null && player!.value.isInitialized
                      ? AspectRatio(aspectRatio: player!.value.aspectRatio,
                        child: VideoPlayer(player!))
                      : const Text('No authorized stream connected')),
                )),
                const SizedBox(height: 20),
                Text(current == null ? 'Select a channel' : 'CH ${current.number}  ${current.title}',
                  style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(current?.description ?? 'Discover broadcasters through a familiar channel guide.',
                  style: const TextStyle(color: Colors.white70, fontSize: 18)),
                const SizedBox(height: 12),
                TvMediaControls(player: player, dvrRightsGranted: false),
                if (diagnosticsVisible && player != null) ...[
                  const SizedBox(height: 8),
                  ...PlaybackDiagnostics(playbackStartedAt).snapshot(player!.value).entries.map(
                    (entry)=>Text('${entry.key}: ${entry.value}',style:const TextStyle(fontSize:13,color:Colors.white70))),
                ],
                const SizedBox(height: 12),
                Text('UP NEXT', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                Text(programmeGuide.isEmpty ? 'Programme schedule pending' :
                  programmeGuide.first.title,
                  style: const TextStyle(color: Colors.white70,fontSize: 17)),
                const SizedBox(height: 12),
                const Text('Live restart and recording require broadcaster rights and DVR infrastructure.',
                  style: TextStyle(color: Colors.white54)),
              ])),
              const SizedBox(width: 28),
              Expanded(flex: 4, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CHANNELS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(child: ListView.builder(
                  controller: scroll,
                  itemCount: channels.length,
                  itemBuilder: (context, i) {
                    final channel = channels[i];
                    final active = selectedIndex == i;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: TvActionTile(
                        label: '${channel.number}   ${channel.title}',
                        description: channel.category,
                        icon: active ? Icons.play_circle_fill : Icons.live_tv,
                        selected: active,
                        onPressed: () => tune(i),
                      ),
                    );
                  },
                )),
              ])),
            ])),
            const SizedBox(height: 14),
            const Text('PREVIEW • Test footage only. Channel rights and production authentication not configured.',
              style: TextStyle(color: Colors.amberAccent, fontSize: 13)),
          ]),
        ),
      )),
    );
  }
}

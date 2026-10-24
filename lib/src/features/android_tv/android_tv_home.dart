import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
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
  bool loading = true;
  int generation = 0;
  final FocusNode guideFocus = FocusNode(debugLabel: 'Guide');
  final ScrollController scroll = ScrollController();

  @override
  void initState() {
    super.initState();
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
    final old = player;
    setState(() { selectedIndex = index; player = null; error = null; });
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
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Material(
                        color: active ? const Color(0xFF205A91) : const Color(0xFF1B2639),
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          canRequestFocus: false,
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => tune(i),
                          child: Padding(padding: const EdgeInsets.all(17), child: Row(children: [
                            Text('${channel.number}', style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 18),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(channel.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 19)),
                              Text(channel.category, style: const TextStyle(color: Colors.white70)),
                            ])),
                            if (active) const Icon(Icons.play_arrow),
                          ])),
                        ),
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

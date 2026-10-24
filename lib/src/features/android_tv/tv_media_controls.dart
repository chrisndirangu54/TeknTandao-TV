import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// DVR capability is separate from ordinary VOD seek: live recording requires
/// broadcaster-approved catch-up backend and must never be implied by UI.
class TvMediaControls extends StatelessWidget {
  final VideoPlayerController? player;
  final bool dvrRightsGranted;
  final VoidCallback? onRequestDvr;
  const TvMediaControls({super.key,this.player,this.dvrRightsGranted=false,this.onRequestDvr});

  @override
  Widget build(BuildContext context) {
    final p=player;
    final playable=p?.value.isInitialized ?? false;
    final duration=playable ? p!.value.duration : Duration.zero;
    final position=playable ? p!.value.position : Duration.zero;
    final seekable=playable && duration.inMilliseconds>0;
    return Column(children: [
      Row(children: [
        IconButton(tooltip:'Rewind 10 seconds',onPressed:seekable ? () =>
          p.seekTo(position-const Duration(seconds:10)<Duration.zero ? Duration.zero :
            position-const Duration(seconds:10)) : null,icon:const Icon(Icons.replay_10)),
        IconButton(tooltip:'Play or pause',onPressed:playable ? () =>
          p.value.isPlaying ? p.pause() : p.play() : null,
          icon:Icon(playable && p!.value.isPlaying ? Icons.pause : Icons.play_arrow)),
        IconButton(tooltip:'Forward 10 seconds',onPressed:seekable ? () =>
          p.seekTo(position+const Duration(seconds:10)>duration ? duration :
            position+const Duration(seconds:10)) : null,icon:const Icon(Icons.forward_10)),
        const Spacer(),
        if (dvrRightsGranted)
          TextButton.icon(onPressed:onRequestDvr,icon:const Icon(Icons.fiber_dvr),label:const Text('Catch-up'))
        else const Text('Catch-up unavailable',style:TextStyle(color:Colors.white60)),
      ]),
      if (seekable) VideoProgressIndicator(p,allowScrubbing:true,
        padding:const EdgeInsets.symmetric(vertical:8)),
      if (playable) Align(alignment:Alignment.centerLeft,
        child:Text('${position.inMinutes}m / ${duration.inMinutes}m',
          style:const TextStyle(color:Colors.white70))),
    ]);
  }
}

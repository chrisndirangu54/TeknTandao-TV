import 'package:video_player/video_player.dart';

/// Device-local diagnostics only. Does not claim to measure network throughput,
/// CDN cache hit rate, or aggregate audience performance.
class PlaybackDiagnostics {
  final DateTime startedAt;
  const PlaybackDiagnostics(this.startedAt);
  Duration get startupElapsed => DateTime.now().difference(startedAt);
  Map<String, String> snapshot(VideoPlayerValue value) => {
    'Resolution': '${value.size.width.round()} × ${value.size.height.round()}',
    'Playing': value.isPlaying ? 'Yes' : 'No',
    'Buffering': value.isBuffering ? 'Yes' : 'No',
    'Position': '${value.position.inSeconds}s',
    'Duration': '${value.duration.inSeconds}s',
    'Playback error': value.errorDescription ?? 'None',
  };
}

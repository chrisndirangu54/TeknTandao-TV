import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models.dart';

/// Device-local preferences. In production sync to a scoped authenticated
/// profile through the backend, not a public Firestore collection.
class TvLibrary {
  final Set<String> favorites = <String>{};
  final Map<String, Duration> progress = <String, Duration>{};
  final Set<String> completed = <String>{};
  final List<String> searches = <String>[];
  String activeProfile = 'Default';
  bool kidsMode = false;
  bool analyticsOptIn = false;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    favorites..clear()..addAll(prefs.getStringList('tvFavorites') ?? const []);
    kidsMode = prefs.getBool('tvKidsMode') ?? false;
    activeProfile = prefs.getString('tvProfile') ?? 'Default';
    analyticsOptIn = prefs.getBool('tvAnalyticsOptIn') ?? false;
    final entries = prefs.getStringList('tvProgress') ?? const [];
    progress.clear();
    for (final entry in entries) {
      final parts = entry.split(':');
      if (parts.length < 2) continue;
      final ms = int.tryParse(parts.last);
      if (ms != null && ms >= 0) {
        progress[parts.sublist(0, parts.length - 1).join(':')] = Duration(milliseconds: ms);
      }
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('tvFavorites', favorites.toList());
    await prefs.setBool('tvKidsMode', kidsMode);
    await prefs.setString('tvProfile', activeProfile);
    await prefs.setBool('tvAnalyticsOptIn', analyticsOptIn);
    await prefs.setStringList('tvProgress',
      progress.entries.map((e) => '${e.key}:${e.value.inMilliseconds}').toList());
  }

  void toggleFavorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
  }
  void recordProgress(String id, Duration position) {
    if (position.isNegative) return;
    progress[id] = position;
  }
  bool visible(TvChannel channel) => !kidsMode ||
    channel.category.toLowerCase() == 'learning' || channel.category.toLowerCase() == 'education';
  List<TvChannel> filter(List<TvChannel> channels, String term) {
    final q = term.trim().toLowerCase();
    return channels.where((c) => visible(c) &&
      (q.isEmpty || ('${c.title} ${c.category} ${c.description} ${c.number}')
        .toLowerCase().contains(q))).toList()..sort((a,b)=>a.number.compareTo(b.number));
  }
}

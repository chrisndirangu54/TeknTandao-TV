import '../../domain/models.dart';

/// Local session state; sync to verified per-user storage after Firebase setup.
class TvLibrary {
  final Set<String> favorites = <String>{};
  final Map<String, Duration> progress = <String, Duration>{};
  final Set<String> completed = <String>{};
  final List<String> searches = <String>[];
  String activeProfile = 'Default';
  bool kidsMode = false;
  bool analyticsOptIn = false;
  void toggleFavorite(String id) => favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
  void recordProgress(String id, Duration position) {
    if (position.isNegative) return;
    progress[id] = position;
  }
  bool visible(TvChannel channel) => !kidsMode ||
    channel.category.toLowerCase() == 'learning' || channel.category.toLowerCase() == 'education';
  List<TvChannel> filter(List<TvChannel> channels,String term) {
    final q=term.trim().toLowerCase();
    return channels.where((c) => visible(c) &&
      (q.isEmpty || ('${c.title} ${c.category} ${c.description} ${c.number}')
        .toLowerCase().contains(q))).toList()..sort((a,b)=>a.number.compareTo(b.number));
  }
}

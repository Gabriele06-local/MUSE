import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local favorites store. Persists only quote ids, nothing else.
class FavoritesStore extends ChangeNotifier {
  FavoritesStore({SharedPreferences? prefs}) : _prefs = prefs;

  static const storageKey = 'muse_favorites_v1';

  SharedPreferences? _prefs;
  final Set<String> _ids = {};

  Set<String> get ids => Set.unmodifiable(_ids);
  int get count => _ids.length;

  bool isFavorite(String id) => _ids.contains(id);

  Future<void> load() async {
    _prefs ??= await SharedPreferences.getInstance();
    final stored = _prefs!.getStringList(storageKey) ?? const <String>[];
    _ids
      ..clear()
      ..addAll(stored);
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.add(id);
    }
    notifyListeners();
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setStringList(storageKey, _ids.toList());
    } catch (_) {
      // Local persistence is best-effort; in-memory state still works.
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'muse_locale.dart';
import 'muse_strings.dart';

/// Holds the active UI language, persists it, detects device language once.
///
/// First launch: Italian device → `it`, everything else → `en`.
/// Stored choice always wins afterwards. Missing Italian keys fall back
/// to English inside [MuseStrings].
class LanguageController extends ChangeNotifier {
  LanguageController({SharedPreferences? prefs}) : _prefs = prefs;

  static const storageKey = 'muse_lang_v1';

  SharedPreferences? _prefs;
  MuseLocale _locale = MuseLocale.en;
  bool _loaded = false;

  MuseLocale get locale => _locale;
  bool get loaded => _loaded;
  MuseStrings get strings => MuseStrings(_locale);

  Future<void> load() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final stored = _prefs!.getString(storageKey);
      if (stored != null) {
        _locale = MuseLocale.fromCode(stored);
      } else {
        final device = PlatformDispatcher.instance.locale.languageCode
            .toLowerCase();
        _locale = device == 'it' ? MuseLocale.it : MuseLocale.en;
      }
    } catch (_) {
      _locale = MuseLocale.en;
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setLocale(MuseLocale next) async {
    if (next == _locale) return;
    _locale = next;
    notifyListeners();
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(storageKey, next.code);
    } catch (_) {
      // Persistence is best-effort; in-memory language still applies.
    }
  }

  void toggle() {
    setLocale(_locale == MuseLocale.en ? MuseLocale.it : MuseLocale.en);
  }
}

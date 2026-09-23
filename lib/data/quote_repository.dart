import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../models/quote.dart';

/// Loads the local dataset and serves quotes without immediate repetition.
///
/// Strategy: keep a shuffled queue of indices. When the queue is exhausted,
/// reshuffle ensuring the first item differs from the last shown. This
/// guarantees no repeats within a full cycle and never twice in a row.
class QuoteDeck extends ChangeNotifier {
  QuoteDeck({Random? random}) : _random = random ?? Random();

  final Random _random;

  List<Quote> _all = const [];
  List<Quote> _pool = const [];
  QuoteCategory? _filter;

  final List<int> _queue = [];
  final List<int> _history = [];
  int _historyPos = -1;
  bool _loaded = false;
  String? _error;

  bool get loaded => _loaded;
  String? get error => _error;
  List<Quote> get all => _all;
  QuoteCategory? get filter => _filter;

  Quote? get current {
    if (!_loaded || _history.isEmpty || _historyPos < 0) return null;
    final poolIndex = _history[_historyPos];
    if (poolIndex < 0 || poolIndex >= _pool.length) return null;
    return _pool[poolIndex];
  }

  bool get canGoBack => _historyPos > 0;

  int get remainingInCycle => _queue.length;

  Future<void> load() async {
    try {
      final raw = await rootBundle.loadString('assets/quotes.json');
      final decoded = json.decode(raw) as List<dynamic>;
      _all = decoded
          .map((e) => Quote.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
      _applyFilter(null, notify: false);
      _loaded = true;
      _error = null;
    } catch (e) {
      _loaded = false;
      _error = 'Could not open the museum rooms.';
    }
    notifyListeners();
  }

  void setFilter(QuoteCategory? category) {
    if (_filter == category) return;
    _applyFilter(category, notify: true);
  }

  void _applyFilter(QuoteCategory? category, {required bool notify}) {
    _filter = category;
    _pool = category == null
        ? _all
        : _all.where((q) => q.category == category).toList(growable: false);
    _queue.clear();
    _history.clear();
    _historyPos = -1;
    if (_pool.isNotEmpty) {
      _refillQueue(excludeIndex: -1);
      _advanceLocked();
    }
    if (notify) notifyListeners();
  }

  void _refillQueue({required int excludeIndex}) {
    _queue.clear();
    if (_pool.isEmpty) return;
    final indices = List<int>.generate(_pool.length, (i) => i);
    // Fisher–Yates with seeded random.
    for (var i = indices.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final tmp = indices[i];
      indices[i] = indices[j];
      indices[j] = tmp;
    }
    // Avoid immediate repetition across cycles.
    if (excludeIndex >= 0 &&
        indices.isNotEmpty &&
        indices.first == excludeIndex &&
        indices.length > 1) {
      final swapWith = 1 + _random.nextInt(indices.length - 1);
      final tmp = indices[0];
      indices[0] = indices[swapWith];
      indices[swapWith] = tmp;
    }
    _queue.addAll(indices);
  }

  void _advanceLocked() {
    if (_pool.isEmpty) return;
    if (_queue.isEmpty) {
      final last = _history.isEmpty ? -1 : _history.last;
      _refillQueue(excludeIndex: last);
    }
    final next = _queue.removeAt(0);
    // Truncate any "forward" history after going back then advancing.
    if (_historyPos < _history.length - 1) {
      _history.removeRange(_historyPos + 1, _history.length);
    }
    _history.add(next);
    // Keep history bounded to avoid unbounded growth.
    if (_history.length > 120) {
      _history.removeAt(0);
    }
    _historyPos = _history.length - 1;
  }

  /// Reveal another quote. Never repeats the current one immediately.
  void next() {
    if (!_loaded || _pool.isEmpty) return;
    // Single-item pool: nothing to change, avoid notify loop.
    if (_pool.length == 1) return;
    _advanceLocked();
    // Safety: if shuffle still produced same (only possible with bugs),
    // advance once more.
    if (_history.length >= 2 &&
        _history[_historyPos] == _history[_historyPos - 1]) {
      _advanceLocked();
    }
    notifyListeners();
  }

  void previous() {
    if (!canGoBack) return;
    _historyPos--;
    notifyListeners();
  }

  /// Quotes by the same author or same room, excluding [exclude].
  List<Quote> related(Quote quote, {int limit = 3}) {
    final sameAuthor = _all.where(
      (q) => q.author == quote.author && q.id != quote.id,
    );
    final sameRoom = _all.where(
      (q) => q.category == quote.category && q.id != quote.id,
    );
    final merged = <Quote>[...sameAuthor, ...sameRoom];
    final seen = <String>{};
    final out = <Quote>[];
    for (final q in merged) {
      if (seen.add(q.id)) {
        out.add(q);
        if (out.length >= limit) break;
      }
    }
    return out;
  }
}

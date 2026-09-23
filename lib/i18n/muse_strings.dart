import '../models/quote.dart';
import 'muse_locale.dart';

/// Lightweight UI strings. Zero dependencies.
///
/// English is the base language. Italian overrides live in [_it].
/// Missing Italian keys fall back to English automatically.
class MuseStrings {
  const MuseStrings(this.locale);

  final MuseLocale locale;

  String _t(String key) => _it[locale.code]?[key] ?? _en[key] ?? key;

  String _tp(String key, Map<String, String> params) {
    var s = _t(key);
    params.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }

  // -- chrome ---------------------------------------------------------------
  String get filterRooms => _t('filterRooms');
  String get showAll => _t('showAll');
  String showLabel(String label) => _tp('showLabel', {'label': label});
  String openSaved(int count) => _tp('openSaved', {'count': '$count'});
  String get savedIcon => _t('savedIcon');
  String get loading => _t('loading');
  String get loadingSemantic => _t('loadingSemantic');
  String get emptyRoom => _t('emptyRoom');
  String get loadError => _t('loadError');

  // -- quote ----------------------------------------------------------------
  String quoteSemantic(String author, String text) =>
      _tp('quoteSemantic', {'author': author, 'text': text});
  String get save => _t('save');
  String get unsave => _t('unsave');
  String readLife(String author) => _tp('readLife', {'author': author});
  String get revealNext => _t('revealNext');
  String get previousQuote => _t('previousQuote');
  String get hint => _t('hint');
  String get swipeHintSemantic => _t('swipeHintSemantic');

  // -- navigation / details ---------------------------------------------------
  String get back => _t('back');
  String get backShort => _t('backShort');
  String get rooms => _t('rooms');
  String get life => _t('life');
  String get nearby => _t('nearby');
  String readQuoteBy(String author) =>
      _tp('readQuoteBy', {'author': author});
  String openQuoteBy(String author) =>
      _tp('openQuoteBy', {'author': author});
  String removeAuthor(String author) =>
      _tp('removeAuthor', {'author': author});
  String get remove => _t('remove');

  // -- favorites ---------------------------------------------------------------
  String get savedBadge => _t('savedBadge');
  String get collectionTitle => _t('collectionTitle');
  String get collectionEmptyHint => _t('collectionEmptyHint');
  String savedCount(int n) => n == 1
      ? _t('savedCountOne')
      : _tp('savedCountMany', {'n': '$n'});
  String get emptyCollectionSemantic => _t('emptyCollectionSemantic');
  String get emptyCollectionLine => _t('emptyCollectionLine');

  // -- language -----------------------------------------------------------------
  String get languageLabel => _t('languageLabel');
  String languageSemantic(String name) =>
      _tp('languageSemantic', {'name': name});

  // -- categories & rooms ---------------------------------------------------------
  String categoryLabel(QuoteCategory c) {
    switch (c) {
      case QuoteCategory.italianEntrepreneurs:
        return _t('catItalian');
      case QuoteCategory.internationalEntrepreneurs:
        return _t('catInternational');
      case QuoteCategory.cinema:
        return _t('catCinema');
      case QuoteCategory.culture:
        return _t('catCulture');
    }
  }

  String roomName(QuoteCategory c) {
    switch (c) {
      case QuoteCategory.italianEntrepreneurs:
        return _t('room1');
      case QuoteCategory.internationalEntrepreneurs:
        return _t('room2');
      case QuoteCategory.cinema:
        return _t('room3');
      case QuoteCategory.culture:
        return _t('room4');
    }
  }
}

const Map<String, String> _en = {
  'filterRooms': 'Filter by room',
  'showAll': 'All',
  'showLabel': 'Show {label}',
  'openSaved': 'Open saved quotes, {count} saved',
  'savedIcon': 'Saved',
  'loading': 'Opening the rooms…',
  'loadingSemantic': 'Loading quotes',
  'emptyRoom': 'This room is empty.',
  'loadError': 'Could not open the museum rooms.',
  'quoteSemantic': 'Quote by {author}. {text}',
  'save': 'Save this quote',
  'unsave': 'Remove from saved',
  'readLife': 'Read life of {author}',
  'revealNext': 'Reveal another quote',
  'previousQuote': 'Previous quote',
  'hint': 'Tap for another · Swipe up or down to wander',
  'swipeHintSemantic':
      'Swipe up for the next quote, swipe down for the previous. Tap for another.',
  'back': 'Go back',
  'backShort': 'Back',
  'rooms': 'Rooms',
  'life': 'LIFE',
  'nearby': 'NEARBY ROOMS',
  'readQuoteBy': 'Read quote by {author}',
  'openQuoteBy': 'Open quote by {author}',
  'removeAuthor': 'Remove {author} from saved',
  'remove': 'Remove',
  'savedBadge': 'SAVED',
  'collectionTitle': 'Your collection',
  'collectionEmptyHint': 'Nothing saved yet — tap the heart in any room.',
  'savedCountOne': '1 memory kept',
  'savedCountMany': '{n} memories kept',
  'emptyCollectionSemantic': 'Empty collection',
  'emptyCollectionLine': 'The museum keeps\nwhat you love.',
  'languageLabel': 'Language',
  'languageSemantic': 'Switch language. Current: {name}',
  'catItalian': 'Italian Entrepreneurs',
  'catInternational': 'International Entrepreneurs',
  'catCinema': 'Cinema',
  'catCulture': 'Culture',
  'room1': 'Room I · Italian Vision',
  'room2': 'Room II · World Builders',
  'room3': 'Room III · Cinema',
  'room4': 'Room IV · Culture',
};

const Map<String, Map<String, String>> _it = {
  'it': {
    'filterRooms': 'Filtra per sala',
    'showAll': 'Tutte',
    'showLabel': 'Mostra {label}',
    'openSaved': 'Apri le citazioni salvate, {count} salvate',
    'savedIcon': 'Salvati',
    'loading': 'Le sale si stanno aprendo…',
    'loadingSemantic': 'Caricamento delle citazioni',
    'emptyRoom': 'Questa sala è vuota.',
    'loadError': 'Non è stato possibile aprire le sale del museo.',
    'quoteSemantic': 'Citazione di {author}. {text}',
    'save': 'Salva questa citazione',
    'unsave': 'Rimuovi dai salvati',
    'readLife': 'Leggi la vita di {author}',
    'revealNext': "Rivela un'altra citazione",
    'previousQuote': 'Citazione precedente',
    'hint': 'Tocca per un’altra · Scorri in alto o in basso per vagare',
    'swipeHintSemantic':
        'Scorri in alto per la successiva, in basso per la precedente. Tocca per un’altra.',
    'back': 'Torna indietro',
    'backShort': 'Indietro',
    'rooms': 'Sale',
    'life': 'VITA',
    'nearby': 'SALE VICINE',
    'readQuoteBy': 'Leggi la citazione di {author}',
    'openQuoteBy': 'Apri la citazione di {author}',
    'removeAuthor': 'Rimuovi {author} dai salvati',
    'remove': 'Rimuovi',
    'savedBadge': 'SALVATI',
    'collectionTitle': 'La tua collezione',
    'collectionEmptyHint':
        'Niente di salvato — tocca il cuore in una sala.',
    'savedCountOne': '1 ricordo custodito',
    'savedCountMany': '{n} ricordi custoditi',
    'emptyCollectionSemantic': 'Collezione vuota',
    'emptyCollectionLine': 'Il museo custodisce\nciò che ami.',
    'languageLabel': 'Lingua',
    'languageSemantic': 'Cambia lingua. Attuale: {name}',
    'catItalian': 'Imprenditori italiani',
    'catInternational': 'Imprenditori internazionali',
    'catCinema': 'Cinema',
    'catCulture': 'Cultura',
    'room1': 'Sala I · Visione italiana',
    'room2': 'Sala II · Costruttori del mondo',
    'room3': 'Sala III · Cinema',
    'room4': 'Sala IV · Cultura',
  },
};

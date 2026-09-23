/// Supported UI languages. English is base/default, Italian is second.
enum MuseLocale {
  en('en', 'English'),
  it('it', 'Italiano');

  const MuseLocale(this.code, this.nativeName);
  final String code;
  final String nativeName;

  static MuseLocale fromCode(String? code) {
    if (code == 'it') return MuseLocale.it;
    return MuseLocale.en;
  }
}

/// Lowercases and strips Czech diacritics so `veze` finds `věže`.
///
/// Used both when writing the catalog search index and when querying it,
/// and by the in-memory area filter — all search comparisons must go
/// through the same normalization.
String normalizeSearchText(String input) {
  const diacritics = 'áčďéěíňóřšťúůýžàäëöü';
  const plain = 'acdeeinorstuuyzaaeou';
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final char = String.fromCharCode(rune);
    final index = diacritics.indexOf(char);
    buffer.write(index >= 0 ? plain[index] : char);
  }
  return buffer.toString().trim();
}

/// [normalizeSearchText] split into whitespace-separated words with SQL
/// LIKE wildcards removed, ready to become `%word%` patterns. Empty for a
/// blank query.
List<String> normalizedSearchWords(String query) => normalizeSearchText(query)
    .replaceAll('%', ' ')
    .replaceAll('_', ' ')
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .toList();

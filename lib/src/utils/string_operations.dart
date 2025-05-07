import 'dart:math';

/// Get the longest common prefix of [first] and [second].
String longestCommonPrefix(String first, String second) {
  final prefix = StringBuffer();
  var i = 0;
  while (i < first.length && i < second.length && first[i] == second[i]) {
    prefix.write(first[i]);
    i++;
  }
  return prefix.toString();
}

/// Search for the last occurence of [pattern] and return everything before
/// and everything after. If [pattern] was not found, returns `('', s)`;
(String, String) splitRight(String s, Pattern pattern) {
  final int i = s.lastIndexOf(pattern);
  if (i == -1) {
    return ('', s);
  } else {
    return (s.substring(0, i), s.substring(i + 1));
  }
}

/// Trim an arbitrary string from the left and right of [s];
String trim(String s, String pattern) {
  String result = s;
  while (result.startsWith(pattern)) {
    result = result.substring(1);
  }
  while (result.endsWith(pattern)) {
    result = result.substring(0, result.length - 1);
  }
  return result;
}

/// Remove/replace unwanted characters from a string.
class ReduceCharacters {
  ReduceCharacters._();
  static final RegExp _nonAllowedChars = RegExp(r'[^a-zA-Z0-9 \-_]');

  /// Removes all unwanted characters.
  static String reduce(String s) => s.replaceAll(_nonAllowedChars, '');

  /// Replace spaces with an underscore.
  static String replaceSpaces(String s) => s.replaceAll(' ', '_');

  /// Removes unwanted characters, replaces spaces with underscores and
  /// truncates the string.
  static String truncateAndClean(String s, {int maxLength = 94}) {
    final String cleaned = replaceSpaces(reduce(s.trim()));
    return cleaned.substring(0, min(cleaned.length, maxLength));
  }
}

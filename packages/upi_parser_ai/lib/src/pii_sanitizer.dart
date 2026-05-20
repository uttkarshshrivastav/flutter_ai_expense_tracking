class PiiSanitizer {
  static final RegExp _upiIdPattern = RegExp(
    r'\b[a-z0-9._-]{2,}@[a-z]{2,}\b',
    caseSensitive: false,
  );

  static final RegExp _explicitNumberPattern = RegExp(
    r'\b(?:a\/?c|ac|account|account\s+no|card|card\s+no|ending\s+in)\s*[:.\-]?\s*(?:x{2,}|\*{2,})?\d{3,}\b',
    caseSensitive: false,
  );

  static final RegExp _maskedNumberPattern = RegExp(
    r'\b(?:x{2,}|\*{2,})\d{3,}\b',
    caseSensitive: false,
  );

  static String sanitize(String input) {
    if (input.isEmpty) return input;

    return input
        .replaceAll(_upiIdPattern, '[UPI_ID_REDACTED]')
        .replaceAll(_explicitNumberPattern, '[NUMBER_REDACTED]')
        .replaceAll(_maskedNumberPattern, '[NUMBER_REDACTED]');
  }
}

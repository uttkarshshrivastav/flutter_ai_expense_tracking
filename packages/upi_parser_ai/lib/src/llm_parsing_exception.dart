
class LlmParsingException implements Exception {
  final String message;
  final dynamic cause;

  LlmParsingException(this.message, [this.cause]);

  @override
  String toString() => 'LlmParsingException: $message';
}

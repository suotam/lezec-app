/// Thrown by the data layer when the bundled demo catalog cannot be parsed.
///
/// Carries a human-oriented [message] describing which part of the document
/// is malformed so problems in the demo asset are easy to locate.
class DemoDataFormatException implements Exception {
  const DemoDataFormatException(this.message);

  final String message;

  @override
  String toString() => 'DemoDataFormatException: $message';
}

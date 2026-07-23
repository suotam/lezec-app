import 'dart:io';
import 'dart:typed_data';

/// Downloads [uri] fully into memory, throwing [HttpException] on any
/// non-200 status. Shared by the catalog updater, weather, photo caching
/// and offline downloads; tests inject fakes instead.
Future<Uint8List> fetchBytes(Uri uri) async {
  final client = HttpClient();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException('HTTP ${response.statusCode} for $uri', uri: uri);
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response) {
      builder.add(chunk);
    }
    return builder.takeBytes();
  } finally {
    client.close();
  }
}

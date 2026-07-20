import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Picks photos from the system gallery, downscaled/re-encoded so a trip
/// with a handful of photos stays around a few hundred kB per image.
Future<List<Uint8List>> pickPhotosFromGallery() async {
  final files = await ImagePicker().pickMultiImage(
    maxWidth: 1600,
    maxHeight: 1600,
    imageQuality: 80,
  );
  return [for (final file in files) await file.readAsBytes()];
}

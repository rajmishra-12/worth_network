import 'package:metadata_fetch/metadata_fetch.dart';

Future<Map<String, dynamic>?> fetchLinkPreview(String url) async {
  try {
    final data = await MetadataFetch.extract(url);

    if (data == null) return null;

    return {
      "title": data.title,
      "description": data.description,
      "image": data.image,
      "url": url,
    };
  } catch (e) {
    return null;
  }
}
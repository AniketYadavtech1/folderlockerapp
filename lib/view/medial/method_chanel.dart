import 'package:flutter/services.dart';

class MediaStoreHelper {
  static const MethodChannel _channel = MethodChannel('media_store');

  /// Delete original media from gallery using MediaStore
  static Future<bool> deleteFromGallery(String path) async {
    try {
      final bool result = await _channel.invokeMethod('deleteFile', {"path": path});
      return result;
    } catch (e) {
      print("MediaStore delete error: $e");
      return false;
    }
  }
}

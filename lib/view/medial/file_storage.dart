import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'db.dart';

class FileStorageHelper {
  static final key = Key.fromUtf8('16CharSecretKey!');
  static final iv = IV.fromLength(16);
  static final encrypter = Encrypter(AES(key));

  static const platform = MethodChannel('com.example.folderlockerapp/refresh');
  static Future<String> _getLockedDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final lockedDir = Directory(join(dir.path, 'locked'));
    if (!await lockedDir.exists()) await lockedDir.create(recursive: true);
    return lockedDir.path;
  }

  static Future<int> lockFile(File file) async {
    final lockedDir = await _getLockedDir();
    final fileName = basename(file.path);
    final lockedPath = join(lockedDir, fileName);
    final bytes = await file.readAsBytes();
    final encrypted = encrypter.encryptBytes(bytes, iv: iv);
    final lockedFile = File(lockedPath);
    await lockedFile.writeAsBytes(encrypted.bytes);
    await file.delete();

    if (Platform.isAndroid) {
      await refreshGallery(file.path);
    }

    return await DBHelper.insertFile(
        {'fileName': fileName, 'originalPath': file.path, 'lockedPath': lockedPath, 'status': 'locked'});
  }

  static Future<void> unlockFile(int id, String lockedPath, String originalPath,
      {bool isIOS = false, bool isAndroid = false}) async {
    final lockedFile = File(lockedPath);
    if (!await lockedFile.exists()) return;

    final encryptedBytes = await lockedFile.readAsBytes();
    final decryptedBytes = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);

    final restoredFile = File(originalPath);
    await restoredFile.writeAsBytes(decryptedBytes);
    await lockedFile.delete();
    if (isAndroid) {
      await refreshGallery(restoredFile.path);
    } else if (isIOS) {
      final bytes = await restoredFile.readAsBytes();
    }

    await DBHelper.updateFile(id, {'status': 'unlocked'});
  }

  static Future<void> refreshGallery(String path) async {
    try {
      await platform.invokeMethod('scanFile', {'path': path});
    } catch (e) {
      print("Failed to refresh gallery: $e");
    }
  }
}

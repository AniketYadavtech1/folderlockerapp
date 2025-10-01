import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class ImageController extends GetxController {
  var lockedImages = <File>[].obs;
  final ImagePicker _picker = ImagePicker();

  // AES Key (must be 32 chars for AES-256)
  final _key = encrypt.Key.fromUtf8('12345678901234567890123456789012');
  final _iv = encrypt.IV.fromLength(16);

  @override
  void onInit() {
    super.onInit();
    loadLockedImages();
  }

  /// Load encrypted files from app storage
  Future<void> loadLockedImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final files = appDir.listSync().where((f) => f.path.endsWith(".enc"));
    lockedImages.value = files.map((e) => File(e.path)).toList();
  }

  /// Encrypt & save picked images
  Future<void> pickAndLockFromGallery() async {
    try {
      final permitted = await PhotoManager.requestPermissionExtend();
      if (!permitted.isAuth) {
        debugPrint("Permission denied!");
        return;
      }

      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;

      final appDir = await getApplicationDocumentsDirectory();
      List<String> assetIdsToDelete = [];

      for (final xfile in picked) {
        final file = File(xfile.path);
        final bytes = await file.readAsBytes();

        // Convert jpg → png
        final decoded = img.decodeImage(bytes);
        if (decoded == null) continue;
        final pngBytes = img.encodePng(decoded);

        // Encrypt
        final encrypter = encrypt.Encrypter(encrypt.AES(_key));
        final encrypted = encrypter.encryptBytes(pngBytes, iv: _iv);

        // Save encrypted file
        final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png.enc";
        final newFile = await File(newPath).writeAsBytes(encrypted.bytes);
        lockedImages.add(newFile);

        // Find asset in gallery
        final albums = await PhotoManager.getAssetPathList(
          onlyAll: true,
          type: RequestType.image,
        );
        if (albums.isEmpty) return;
        final album = albums.first;
        final total = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: picked.length);

        for (final asset in assets) {
          final assetFile = await asset.file;

          //  use AND instead of OR
          if (assetFile != null && assetFile.path == file.path) {
            // delete only this picked asset
            await PhotoManager.editor.deleteWithIds([asset.id]);
            debugPrint("Deleted from gallery: ${assetFile.path}");
            break; // stop after match
          }
        }
      }

      if (assetIdsToDelete.isNotEmpty) {
        await PhotoManager.editor.deleteWithIds(assetIdsToDelete);
        debugPrint("Deleted ${assetIdsToDelete.length} selected images from gallery.");
      }
    } catch (e, st) {
      debugPrint("pickAndLockFromGallery error: $e\n$st");
    }
  }

  /// Decrypt and return image bytes
  Future<Uint8List> decryptImage(File encFile) async {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encryptedBytes = await encFile.readAsBytes();
    final decrypted = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: _iv);
    return Uint8List.fromList(decrypted);
  }

  /// Unlock (restore) image back to public storage
  Future<void> unlockImage(File lockedFile) async {
    try {
      final decryptedBytes = await decryptImage(lockedFile);

      // Save back to gallery folder
      final picturesDir = Directory('/storage/emulated/0/Pictures/UnlockedImages');
      if (!picturesDir.existsSync()) {
        picturesDir.createSync(recursive: true);
      }
      final restoredPath = '${picturesDir.path}/restored_${DateTime.now().millisecondsSinceEpoch}.png';
      final restoredFile = await File(restoredPath).writeAsBytes(decryptedBytes);

      // Delete encrypted file
      if (await lockedFile.exists()) {
        await lockedFile.delete();
      }

      lockedImages.remove(lockedFile);
      debugPrint("Restored to gallery: ${restoredFile.path}");
    } catch (e) {
      debugPrint("unlockImage error: $e");
    }
  }
}

class IncreptionDecreption extends StatelessWidget {
  const IncreptionDecreption({super.key});

  @override
  Widget build(BuildContext context) {
    final ImageController controller = Get.put(ImageController());

    return Scaffold(
      appBar: AppBar(title: const Text("Increption")),
      body: Obx(() {
        if (controller.lockedImages.isEmpty) {
          return const Center(child: Text("No images locked yet"));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
          ),
          itemCount: controller.lockedImages.length,
          itemBuilder: (context, index) {
            final file = controller.lockedImages[index];
            return FutureBuilder<Uint8List>(
              future: controller.decryptImage(file),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                return GestureDetector(
                  onTap: () async {
                    // Full preview
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          appBar: AppBar(),
                          body: Center(
                            child: Image.memory(snapshot.data!, fit: BoxFit.contain),
                          ),
                        ),
                      ),
                    );
                  },
                  onLongPress: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text("Unlock Image"),
                        content: const Text("Do you want to unlock this image?"),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
                          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      controller.unlockImage(file);
                    }
                  },
                  child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                );
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.pickAndLockFromGallery(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

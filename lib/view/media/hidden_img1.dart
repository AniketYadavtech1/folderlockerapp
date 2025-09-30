import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/database.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class PickController extends GetxController {
  var lockedImages = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadLockedImages();
  }

  Future<void> loadLockedImages() async {
    final data = await DBHelper.getImages();
    lockedImages.value = data.map((e) => File(e["path"])).toList();
  }

  Future<void> unlockImage(File lockedFile) async {
    try {
      // 1. Create a folder in public storage to restore
      final picturesDir = Directory('/storage/emulated/0/Pictures/UnlockedImages');
      if (!picturesDir.existsSync()) {
        picturesDir.createSync(recursive: true);
      }

      // 2. Generate a new file path
      final restoredPath = '${picturesDir.path}/restored_${DateTime.now().millisecondsSinceEpoch}.jpg';

      // 3. Copy the locked image back to public storage
      final restoredFile = await lockedFile.copy(restoredPath);

      // 4. Remove from app storage
      if (await lockedFile.exists()) {
        await lockedFile.delete();
      }

      // 5. Remove from DB & update UI
      await DBHelper.deleteImage(lockedFile.path);
      lockedImages.remove(lockedFile);

      debugPrint("Restored to gallery: ${restoredFile.path}");
    } catch (e) {
      debugPrint("unlockImage error: $e");
    }
  }

  final ImagePicker _picker = ImagePicker();
  Future<void> pickAndLockFromGallery() async {
    try {
      // 1. Ask gallery permission
      final permitted = await PhotoManager.requestPermissionExtend();
      if (!permitted.isAuth) {
        debugPrint("Permission denied!");
        return;
      }

      // 2. Pick images using native gallery
      final picked = await _picker.pickMultiImage();
      if (picked.isEmpty) return;

      final appDir = await getApplicationDocumentsDirectory();
      List<String> assetIdsToDelete = [];
      for (final xfile in picked) {
        final file = File(xfile.path);

        // 3. Copy to app folder
        final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        final newFile = await file.copy(newPath);
        lockedImages.add(newFile);

        // 4. Delete original from gallery
        // Get all assets in "All Photos"
        final albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
        if (albums.isEmpty) return;
        final album = albums.first;
        final total = await album.assetCountAsync;
        final assets = await album.getAssetListRange(start: 0, end: total);
        // Find the asset that matches this file path
        for (final asset in assets) {
          final assetFile = await asset.file;
          if (assetFile != null || assetFile?.path == file.path) {
            assetIdsToDelete.add(asset.id);
          }
        }
        break;
      }

      if (assetIdsToDelete.isNotEmpty) {
        await PhotoManager.editor.deleteWithIds(assetIdsToDelete.toList());
        debugPrint("Deleted ${assetIdsToDelete.length} selected images from gallery.");
      }
    } catch (e, st) {
      debugPrint("pickAndLockFromGallery error: $e\n$st");
    }
  }
}

class HiddenImageView1 extends StatelessWidget {
  const HiddenImageView1({super.key});

  @override
  Widget build(BuildContext context) {
    final PickController controller = Get.put(PickController());

    return Scaffold(
      appBar: AppBar(title: const Text("Hidden Image 2")),
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
            return GestureDetector(
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
              child: Image.file(file, fit: BoxFit.cover),
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

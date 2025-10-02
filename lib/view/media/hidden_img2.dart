import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/database.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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

  Future<void> pickAndLockMultipleImages(BuildContext context) async {
    try {
      if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {}
      // 1. Request permission
      final permitted = await PhotoManager.requestPermissionExtend();
      if (!permitted.isAuth) {
        debugPrint("Permission denied!");
        return;
      }
      // 2. Get all images from gallery
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );
      if (albums.isEmpty) return;
      final AssetPathEntity album = albums.first;
      final int total = await album.assetCountAsync;
      final List<AssetEntity> allAssets = await album.getAssetListRange(start: 0, end: total);
      // 3. Show multi-select dialog
      final List<AssetEntity> selectedAssets = await showDialog(
        context: context,
        builder: (ctx) {
          List<AssetEntity> tempSelected = [];
          return StatefulBuilder(
            builder: (ctx, setState) {
              return AlertDialog(
                title: Text("Select Images (${tempSelected.length})"),
                content: SizedBox(
                  width: MediaQuery.sizeOf(context).width,
                  height: MediaQuery.sizeOf(context).width,
                  child: GridView.builder(
                    itemCount: allAssets.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 5),
                    itemBuilder: (context, index) {
                      final asset = allAssets[index];
                      return FutureBuilder<File?>(
                        future: asset.file,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Container(color: Colors.grey);
                          final file = snapshot.data!;
                          final isSelected = tempSelected.contains(asset);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  tempSelected.remove(asset);
                                } else {
                                  tempSelected.add(asset);
                                }
                              });
                            },
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.file(file, fit: BoxFit.cover),
                                if (isSelected)
                                  Container(
                                    color: Colors.black54,
                                    child: const Icon(Icons.check_circle, color: Colors.white, size: 30),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.pop(ctx, tempSelected);
                      },
                      child: const Text("Done"))
                ],
              );
            },
          );
        },
      );

      if (selectedAssets.isEmpty) return;

      // 4. App-private folder
      final appDir = await getApplicationDocumentsDirectory();

      // 5. Copy selected images to app folder & delete from gallery
      for (final asset in selectedAssets) {
        final file = await asset.file;
        if (file == null) continue;

        final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        final newFile = await file.copy(newPath);

        // Save to DB
        await DBHelper.insertImage(newFile.path);
        lockedImages.add(newFile);

        // Delete from gallery
        await PhotoManager.editor.deleteWithIds([asset.id]);
        debugPrint("Deleted from gallery: ${file.path}");
      }
    } catch (e, st) {
      debugPrint("pickAndLockMultipleImages error: $e\n$st");
    }
  }
}

class HiddenImageView2 extends StatelessWidget {
  const HiddenImageView2({super.key});

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
        onPressed: () => controller.pickAndLockMultipleImages(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

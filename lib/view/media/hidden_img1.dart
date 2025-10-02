import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

class PickControllers extends GetxController {
  var lockedImages = <File>[].obs;
  final ImagePicker picker = ImagePicker();
  late Box<String> box;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box<String>('locked_images');
    loadLockedImages();
  }

  void loadLockedImages() {
    lockedImages.value = box.values.map((path) => File(path)).toList();
  }

  Future<void> pickAndLockFromGallery() async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      debugPrint("Permission denied!");
      return;
    }

    final picked = await picker.pickMultiImage();
    if (picked.isEmpty) return;
    for (final xfile in picked) {
      final appDir = await getApplicationDocumentsDirectory();
      final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${xfile.name}";
      final newFile = await File(xfile.path).copy(newPath);
      await box.put(newPath, newPath);
      lockedImages.add(newFile);
    }
    await deleteFromGallery(picked);
  }

  Future<void> deleteFromGallery(List<XFile> pickedFiles) async {
    try {
      List<String> idsToDelete = [];
      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(onlyAll: true);
      final List<AssetEntity> allAssets = await paths.first.getAssetListRange(start: 0, end: pickedFiles.length);
      for (final xfile in pickedFiles) {
        for (final asset in allAssets) {
          final file = await asset.file;
          if (file != null || file?.path == xfile.path) {
            idsToDelete.add(asset.id);
          }
        }
      }
      idsToDelete = idsToDelete.toSet().toList();
      if (idsToDelete.isNotEmpty) {
        final deletedList = await PhotoManager.editor.deleteWithIds(idsToDelete);
        debugPrint("Deleted ${deletedList.length} images from gallery.");
      } else {
        debugPrint("No matching assets found to delete.");
      }
    } catch (e) {
      debugPrint("deleteFromGallery error: $e");
    }
  }

  Future<void> unlockImage(File lockedFile) async {
    try {
      final picturesDir = Directory('/storage/emulated/0/Pictures/UnlockedImages');
      if (!picturesDir.existsSync()) {
        picturesDir.createSync(recursive: true);
      }
      final restoredPath = '${picturesDir.path}/restored_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await lockedFile.copy(restoredPath);
      if (await lockedFile.exists()) {
        await lockedFile.delete();
      }
      final key = box.keys.firstWhere(
        (k) => box.get(k) == lockedFile.path,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
      }
      lockedImages.remove(lockedFile);
      debugPrint("Unlocked to: $restoredPath");
    } catch (e) {
      debugPrint("unlockImage error: $e");
    }
  }

  Future<void> deleteLockedImage(File lockedFile) async {
    try {
      if (await lockedFile.exists()) {
        await lockedFile.delete();
      }
      final key = box.keys.firstWhere(
        (k) => box.get(k) == lockedFile.path,
        orElse: () => null,
      );
      if (key != null) {
        await box.delete(key);
      }
      lockedImages.remove(lockedFile);
      debugPrint("Deleted locked image: ${lockedFile.path}");
    } catch (e) {
      debugPrint("deleteLockedImage error: $e");
    }
  }

  void swapImages(int oldIndex, int newIndex) {
    final temp = lockedImages[oldIndex];
    lockedImages.removeAt(oldIndex);
    lockedImages.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, temp);
  }
}

class HiddenImageView1 extends StatelessWidget {
  const HiddenImageView1({super.key});

  @override
  Widget build(BuildContext context) {
    final PickControllers controller = Get.put(PickControllers());

    return Scaffold(
      appBar: AppBar(title: const Text("Hidden Images")),
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FullImageView(file: file),
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
              child: SizedBox(
                child: Stack(children: [
                  Image.file(
                    file,
                    fit: BoxFit.contain,
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      controller.deleteLockedImage(file);
                    },
                  )
                ]),
              ),
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

class FullImageView extends StatelessWidget {
  final File file;
  const FullImageView({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Center(
        child: Image.file(file, fit: BoxFit.contain),
      ),
    );
  }
}

void _showNoteDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Your gallery is not delete"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 10),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // cancel button
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // save button
            },
            child: const Text("Save"),
          ),
        ],
      );
    },
  );
}

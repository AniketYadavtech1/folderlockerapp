// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:photo_manager/photo_manager.dart';
//
// import 'database.dart';
//
// class PickController extends GetxController {
//   var lockedImages = <File>[].obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     loadLockedImages();
//   }
//
//   Future<void> loadLockedImages() async {
//     final data = await DBHelper.getImages();
//     lockedImages.value = data.map((e) => File(e["path"])).toList();
//   }
//
//   // Future<void> pickAndLockFromDeviceGallery() async {
//   //   try {
//   //     // Request permission
//   //     if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
//   //       return;
//   //     }
//   //
//   //     final ImagePicker picker = ImagePicker();
//   //     final List<XFile> pickedFiles = await picker.pickMultiImage();
//   //     if (pickedFiles.isEmpty) return;
//   //
//   //     final appDir = await getApplicationDocumentsDirectory();
//   //
//   //     // Load assets (all images)
//   //     final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
//   //     if (albums.isEmpty) return;
//   //     final AssetPathEntity album = albums.first;
//   //     final int total = await album.assetCountAsync;
//   //     final List<AssetEntity> assets = await album.getAssetListRange(start: 0, end: total);
//   //
//   //     for (final xfile in pickedFiles) {
//   //       final originalPath = xfile.path;
//   //       final file = File(originalPath);
//   //
//   //       // Copy to app storage
//   //       final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png";
//   //       final newFile = await file.copy(newPath);
//   //       await DBHelper.insertImage(newFile.path);
//   //       lockedImages.add(newFile);
//   //
//   //       // Try to match and delete from gallery
//   //       AssetEntity? match;
//   //       for (final asset in assets) {
//   //         await PhotoManager.editor.deleteWithIds([asset.id]);
//   //         final assetFile = await asset.file;
//   //         if (assetFile?.path == originalPath) {
//   //           match = asset;
//   //           break;
//   //         }
//   //       }
//   //       if (match != null) {
//   //         await PhotoManager.editor.deleteWithIds([match.id]);
//   //         debugPrint("Deleted from gallery: $originalPath");
//   //       } else {
//   //         if (await file.exists()) {
//   //           await file.delete();
//   //           debugPrint("Deleted by File API: $originalPath");
//   //         }
//   //       }
//   //     }
//   //   } catch (e, st) {
//   //     debugPrint("pickAndLockFromDeviceGallery error: $e\n$st");
//   //   }
//   // }
//
//   // Future<void> pickAndLockMultipleImages() async {
//   //   try {
//   //     // 1. Request permissions
//   //     if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
//   //       return;
//   //     }
//   //
//   //     final ImagePicker picker = ImagePicker();
//   //     final List<XFile> pickedFiles = await picker.pickMultiImage();
//   //     if (pickedFiles.isEmpty) return;
//   //
//   //     // 2. App-private folder
//   //     final appDir = await getApplicationDocumentsDirectory();
//   //
//   //     // 3. Load all gallery assets
//   //     final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(onlyAll: true, type: RequestType.image);
//   //     if (albums.isEmpty) return;
//   //     final AssetPathEntity album = albums.first;
//   //     final int total = await album.assetCountAsync;
//   //     final List<AssetEntity> assets = await album.getAssetListRange(start: 0, end: total);
//   //
//   //     // 4. Loop over picked images
//   //     for (final xfile in pickedFiles) {
//   //       final file = File(xfile.path);
//   //
//   //       // Copy to app-private folder
//   //       final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
//   //       final newFile = await file.copy(newPath);
//   //
//   //       // Save to DB
//   //       await DBHelper.insertImage(newFile.path);
//   //       lockedImages.add(newFile);
//   //
//   //       // Match and delete from gallery using PhotoManager
//   //       AssetEntity? match;
//   //       for (final asset in assets) {
//   //         await PhotoManager.editor.deleteWithIds([asset.id]);
//   //         final assetFile = await asset.file;
//   //         if (assetFile?.path == xfile.path) {
//   //           match = asset;
//   //           break;
//   //         }
//   //       }
//   //
//   //       if (match != null) {
//   //         await PhotoManager.editor.deleteWithIds([match.id]);
//   //         debugPrint("Deleted from gallery: ${xfile.path}");
//   //       } else {
//   //         // fallback delete cache
//   //         if (await file.exists()) {
//   //           await file.delete();
//   //           debugPrint("Deleted cache only: ${xfile.path}");
//   //         }
//   //       }
//   //     }
//   //   } catch (e, st) {
//   //     debugPrint("pickAndLockMultipleImages error: $e\n$st");
//   //   }
//   // }
//
//   Future<void> pickAndLockMultipleImages(BuildContext context) async {
//     try {
//       // 1. Request permission
//       final permitted = await PhotoManager.requestPermissionExtend();
//       if (!permitted.isAuth) {
//         debugPrint("Permission denied!");
//         return;
//       }
//
//       // 2. Pick assets from gallery
//       List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
//         onlyAll: true,
//         type: RequestType.image,
//       );
//
//       if (pickedAssets == null || pickedAssets.isEmpty) return;
//
//       // 3. App-private folder
//       final appDir = await getApplicationDocumentsDirectory();
//
//       // 4. Loop through selected images
//       for (final asset in pickedAssets) {
//         final file = await asset.file;
//         if (file == null) continue;
//
//         // Copy to app folder
//         final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
//         final newFile = await file.copy(newPath);
//
//         // Save to DB
//         await DBHelper.insertImage(newFile.path);
//         lockedImages.add(newFile);
//
//         // Delete from gallery
//         final success = await PhotoManager.editor.deleteWithIds([asset.id]);
//       }
//     } catch (e, st) {
//       debugPrint("pickAndLockMultipleImages error: $e\n$st");
//     }
//   }
//
//   Future<void> unlockImage(File lockedFile) async {
//     final picturesDir = Directory('/storage/emulated/0/Pictures');
//     if (!picturesDir.existsSync()) {
//       picturesDir.createSync(recursive: true);
//     }
//
//     final restoredPath = '${picturesDir.path}/restored_${DateTime.now().millisecondsSinceEpoch}.png';
//     final restoredFile = await lockedFile.copy(restoredPath);
//
//     if (await lockedFile.exists()) {
//       await lockedFile.delete();
//     }
//     await DBHelper.deleteImage(lockedFile.path);
//     lockedImages.remove(lockedFile);
//
//     debugPrint("Restored: ${restoredFile.path}");
//   }
// }
//
// class SecureImageVaultView extends StatelessWidget {
//   const SecureImageVaultView({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final PickController controller = Get.put(PickController());
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Secure (SQLite + FilePicker + GetX)")),
//       body: Obx(() {
//         if (controller.lockedImages.isEmpty) {
//           return const Center(child: Text("No images locked yet"));
//         }
//         return GridView.builder(
//           padding: const EdgeInsets.all(8),
//           gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//             crossAxisCount: 3,
//             crossAxisSpacing: 5,
//             mainAxisSpacing: 5,
//           ),
//           itemCount: controller.lockedImages.length,
//           itemBuilder: (context, index) {
//             final file = controller.lockedImages[index];
//             return GestureDetector(
//               onLongPress: () => controller.unlockImage(file),
//               child: Image.file(file, fit: BoxFit.cover),
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => controller.pickAndLockMultipleImages(context),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
// updated code

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import 'database.dart';

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

  Future<void> pickAndLockMultipleImages(BuildContext context) async {
    try {
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
                  width: double.maxFinite,
                  height: 400,
                  child: GridView.builder(
                    itemCount: allAssets.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, crossAxisSpacing: 5, mainAxisSpacing: 5),
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

  Future<void> unlockImage(File lockedFile) async {
    final picturesDir = Directory('/storage/emulated/0/Pictures');
    if (!picturesDir.existsSync()) {
      picturesDir.createSync(recursive: true);
    }

    final restoredPath = '${picturesDir.path}/restored_${DateTime.now().millisecondsSinceEpoch}.png';
    final restoredFile = await lockedFile.copy(restoredPath);

    if (await lockedFile.exists()) {
      await lockedFile.delete();
    }
    await DBHelper.deleteImage(lockedFile.path);
    lockedImages.remove(lockedFile);

    debugPrint("Restored: ${restoredFile.path}");
  }
}

class SecureImageVaultView extends StatelessWidget {
  const SecureImageVaultView({super.key});

  @override
  Widget build(BuildContext context) {
    final PickController controller = Get.put(PickController());

    return Scaffold(
      appBar: AppBar(title: const Text("Secure Image Vault")),
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
              onLongPress: () => controller.unlockImage(file),
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

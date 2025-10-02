// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:hive/hive.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:photo_manager/photo_manager.dart';
//
// /// Controller
// class PickControllers extends GetxController {
//   var lockedImages = <File>[].obs;
//   final ImagePicker _picker = ImagePicker();
//   late Box<String> box;
//
//   @override
//   void onInit() {
//     super.onInit();
//     box = Hive.box<String>('locked_images');
//     loadLockedImages();
//   }
//
//   /// Load locked images from Hive
//   void loadLockedImages() {
//     lockedImages.value = box.values.map((path) => File(path)).toList();
//   }
//
//   /// Pick images and lock them
//   Future<void> pickAndLockFromGallery() async {
//     final permitted = await PhotoManager.requestPermissionExtend();
//     if (!permitted.isAuth) {
//       debugPrint("Permission denied!");
//       return;
//     }
//
//     // Pick images
//     final picked = await _picker.pickMultiImage();
//     if (picked.isEmpty) return;
//
//     for (final xfile in picked) {
//       // 1. Copy to app private storage
//       final appDir = await getApplicationDocumentsDirectory();
//       final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${xfile.name}";
//       final newFile = await File(xfile.path).copy(newPath);
//
//       // 2. Save in Hive
//       await box.put(newPath, newPath);
//       lockedImages.add(newFile);
//     }
//     // 3. Delete originals from gallery
//     await deleteFromGallery(picked);
//   }
//
//   /// Delete selected images from gallery using PhotoManager
//   /// Delete selected images from gallery using PhotoManager
//   // Future<void> deleteFromGallery(List<XFile> pickedFiles) async {
//   //   try {
//   //     List<String> idsToDelete = [];
//   //     // Get all assets from gallery
//   //     final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(onlyAll: true);
//   //     final List<AssetEntity> allAssets = await paths.first.getAssetListRange(start: 0, end: 100000);
//   //     for (final xfile in pickedFiles) {
//   //       for (final asset in allAssets) {
//   //         final file = await asset.file;
//   //         if (file != null || file?.path == xfile.path) {
//   //           idsToDelete.add(asset.id);
//   //           break; // stop once match is found
//   //         }
//   //       }
//   //     }
//   //
//   //     if (idsToDelete.isNotEmpty) {
//   //       final deletedCount = await PhotoManager.editor.deleteWithIds(idsToDelete);
//   //       debugPrint("Deleted $deletedCount images from gallery.");
//   //     } else {
//   //       debugPrint("No matching assets found to delete.");
//   //     }
//   //   } catch (e) {
//   //     debugPrint("deleteFromGallery error: $e");
//   //   }
//   // }
//   Future<void> deleteFromGallery(List<XFile> pickedFiles) async {
//     try {
//       List<String> idsToDelete = [];
//       // Get all assets from gallery
//       final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(onlyAll: true);
//       final List<AssetEntity> allAssets = await paths.first.getAssetListRange(start: 0, end: pickedFiles.length);
//       // Match selected images with gallery assets
//       for (final xfile in pickedFiles) {
//         for (final asset in allAssets) {
//           final file = await asset.file;
//           if (file != null || file?.path == xfile.path) {
//             idsToDelete.add(asset.id);
//             //  Don't break — allow multiple matches
//           }
//         }
//       }
//       // Delete matched assets
//       idsToDelete = idsToDelete.toSet().toList();
//       if (idsToDelete.isNotEmpty) {
//         final deletedList = await PhotoManager.editor.deleteWithIds(idsToDelete);
//         debugPrint("Deleted ${deletedList.length} images from gallery.");
//       } else {
//         debugPrint("No matching assets found to delete.");
//       }
//     } catch (e) {
//       debugPrint("deleteFromGallery error: $e");
//     }
//   }
//   // Future<void> deleteFromGallery(List<XFile> pickedFiles) async {
//   //   try {
//   //     List<String> idsToDelete = [];
//   //
//   //     final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(onlyAll: true);
//   //     final AssetPathEntity gallery = paths.first;
//   //
//   //     // Fetch only as many assets as picked images (latest ones)
//   //     final int endRange = pickedFiles.length;
//   //     final List<AssetEntity> recentAssets = await gallery.getAssetListRange(start: 0, end: endRange);
//   //
//   //     // Match picked images with gallery assets
//   //     for (final xfile in pickedFiles) {
//   //       for (final asset in recentAssets) {
//   //         final file = await asset.file;
//   //         if (file != null || file?.path == xfile.path) {
//   //           idsToDelete.add(asset.id);
//   //           break; // ek match mila → agli file check karo
//   //         }
//   //       }
//   //     }
//   //     // Remove duplicates just in case
//   //     idsToDelete = idsToDelete.toSet().toList();
//   //     print("Aniket ${idsToDelete}");
//   //     print("Aniket Length ${idsToDelete.length}");
//   //
//   //     if (idsToDelete.isNotEmpty) {
//   //       final deleted = await PhotoManager.editor.deleteWithIds(idsToDelete);
//   //       print("Aniket Two${idsToDelete.length}");
//   //       debugPrint("Deleted ${deleted.length} images from gallery.");
//   //     } else {
//   //       debugPrint("No matching assets found to delete.");
//   //     }
//   //   } catch (e) {
//   //     debugPrint("deleteFromGallery error: $e");
//   //   }
//   // }
//
//   /// Unlock image back to public storage
//   Future<void> unlockImage(File lockedFile) async {
//     try {
//       final picturesDir = Directory('/storage/emulated/0/Pictures/UnlockedImages');
//       if (!picturesDir.existsSync()) {
//         picturesDir.createSync(recursive: true);
//       }
//       final restoredPath = '${picturesDir.path}/restored_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       await lockedFile.copy(restoredPath);
//
//       // Delete from app storage
//       if (await lockedFile.exists()) {
//         await lockedFile.delete();
//       }
//
//       // Remove from Hive
//       final key = box.keys.firstWhere(
//             (k) => box.get(k) == lockedFile.path,
//         orElse: () => null,
//       );
//       if (key != null) {
//         await box.delete(key);
//       }
//
//       lockedImages.remove(lockedFile);
//       debugPrint("Unlocked to: $restoredPath");
//     } catch (e) {
//       debugPrint("unlockImage error: $e");
//     }
//   }
// }
//
// /// Main UI
// class HiddenImageView1 extends StatelessWidget {
//   const HiddenImageView1({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final PickControllers controller = Get.put(PickControllers());
//
//     return Scaffold(
//       appBar: AppBar(title: const Text("Hidden Images")),
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
//               onTap: () {
//                 // Fullscreen viewer
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (_) => FullImageView(file: file),
//                   ),
//                 );
//               },
//               onLongPress: () async {
//                 final confirm = await showDialog<bool>(
//                   context: context,
//                   builder: (ctx) => AlertDialog(
//                     title: const Text("Unlock Image"),
//                     content: const Text("Do you want to unlock this image?"),
//                     actions: [
//                       TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("No")),
//                       TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Yes")),
//                     ],
//                   ),
//                 );
//                 if (confirm == true) {
//                   controller.unlockImage(file);
//                 }
//               },
//               child: Image.file(file, fit: BoxFit.cover),
//             );
//           },
//         );
//       }),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () => controller.pickAndLockFromGallery(),
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
//
// /// Fullscreen image viewer
// class FullImageView extends StatelessWidget {
//   final File file;
//   const FullImageView({super.key, required this.file});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Image.file(file, fit: BoxFit.contain),
//       ),
//     );
//   }
// }
//
// // Future<void> main() async {
// //   WidgetsFlutterBinding.ensureInitialized();
// //   await Hive.initFlutter();
// //   await Hive.openBox<String>('locked_images');
// //   runApp(const MyApp());
// // }
//
// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});
// //   @override
// //   Widget build(BuildContext context) {
// //     return GetMaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: const HiddenImageView1(),
// //     );
// //   }
// // }

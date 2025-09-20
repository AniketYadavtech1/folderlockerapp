// import 'dart:convert';
// import 'dart:io';
//
// import 'package:file_picker/file_picker.dart';
// import 'package:folderlockerapp/view/folder/controller/controller.dart';
// import 'package:folderlockerapp/view/media/controller/controller.dart';
// import 'package:get/get.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:photo_manager/photo_manager.dart';
//
// class FolderLockerController extends GetxController {
//   final RxList<LockedFolder> lockedFolders = <LockedFolder>[].obs;
//   final RxList<LockedMedia> lockedMedia = <LockedMedia>[].obs;
//
//   late Directory appDocDir;
//   final String indexFileName = 'locked_index.json';
//   final String mediaIndexFileName = 'locked_media.json';
//
//   @override
//   void onInit() {
//     super.onInit();
//     initPaths();
//   }
//
//   Future<void> initPaths() async {
//     appDocDir = await getApplicationDocumentsDirectory();
//
//     // LockedMedia folder ensure करो
//     final destParent = Directory('${appDocDir.path}/LockedMedia');
//     if (!await destParent.exists()) {
//       await destParent.create(recursive: true);
//       final nomedia = File('${destParent.path}/.nomedia');
//       if (!await nomedia.exists()) {
//         await nomedia.create();
//       }
//     }
//
//     await loadMediaIndex();
//   }
//
//   /// 🔒 Save / Load Multimedia Index
//   Future<File> mediaIndexFile() async {
//     final f = File('${appDocDir.path}/$mediaIndexFileName');
//     if (!await f.exists()) await f.create();
//     return f;
//   }
//
//   Future<void> loadMediaIndex() async {
//     final f = await mediaIndexFile();
//     try {
//       final text = await f.readAsString();
//       if (text.trim().isEmpty) {
//         lockedMedia.value = [];
//         return;
//       }
//       final data = jsonDecode(text) as List<dynamic>;
//       lockedMedia.value = data.map((e) => LockedMedia.fromJson(e)).toList();
//     } catch (_) {
//       lockedMedia.value = [];
//     }
//   }
//
//   Future<void> saveMediaIndex() async {
//     final f = await mediaIndexFile();
//     final data = lockedMedia.map((e) => e.toJson()).toList();
//     await f.writeAsString(jsonEncode(data));
//   }
//
//   /// 📂 Pick Image/Video and Lock
//   Future<void> pickAndLockMedia({required bool isVideo, bool moveInsteadOfCopy = true}) async {
//     if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
//       Get.snackbar("Permission Denied", "Please allow storage permission!");
//       return;
//     }
//
//     final result = await FilePicker.platform.pickFiles(
//       type: isVideo ? FileType.video : FileType.image,
//       allowMultiple: true,
//     );
//
//     if (result == null) return;
//
//     final mediaFiles = result.paths.whereType<String>().map((path) => File(path)).toList();
//     final destParent = Directory('${appDocDir.path}/LockedMedia');
//
//     for (var file in mediaFiles) {
//       final fileName = file.uri.pathSegments.last;
//       final id = DateTime.now().millisecondsSinceEpoch.toString();
//       final destFile = File('${destParent.path}/$id\_$fileName');
//
//       try {
//         await destFile.writeAsBytes(await file.readAsBytes());
//
//         if (moveInsteadOfCopy && await file.exists()) {
//           try {
//             await file.delete();
//             // Gallery को notify करें
//             PhotoManager.editor.deleteWithIds([file.path]);
//           } catch (_) {
//             Get.snackbar("Warning", "Copied but could not delete original.");
//           }
//         }
//
//         final locked = LockedMedia(
//           id: id,
//           originalPath: file.path,
//           storedPath: destFile.path,
//           type: isVideo ? "video" : "image",
//           lockedAt: DateTime.now(),
//         );
//
//         lockedMedia.add(locked);
//         await saveMediaIndex();
//       } catch (e) {
//         Get.snackbar("Error", e.toString());
//       }
//     }
//
//     Get.snackbar("Success", "${isVideo ? "Video(s)" : "Image(s)"} locked securely!");
//   }
//
//   /// 🔓 Unlock Media
//   Future<void> unlockMedia(LockedMedia media, {bool moveInsteadOfCopy = true}) async {
//     if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
//       Get.snackbar("Permission Denied", "Please allow storage permission!");
//       return;
//     }
//
//     final srcFile = File(media.storedPath);
//     if (!await srcFile.exists()) {
//       Get.snackbar("Error", "Locked file not found!");
//       return;
//     }
//
//     final destFile = File(media.originalPath);
//     try {
//       await destFile.writeAsBytes(await srcFile.readAsBytes());
//
//       if (moveInsteadOfCopy) {
//         try {
//           await srcFile.delete();
//         } catch (_) {
//           Get.snackbar("Warning", "Restored but could not delete from app storage.");
//         }
//       }
//
//       // Gallery को notify करें कि नया media add हुआ है
//       await PhotoManager.editor.saveImageWithPath(destFile.path);
//
//       lockedMedia.removeWhere((f) => f.id == media.id);
//       await saveMediaIndex();
//
//       Get.snackbar("Success", "${media.type} restored at: ${media.originalPath}");
//     } catch (e) {
//       Get.snackbar("Error", e.toString());
//     }
//   }
// }

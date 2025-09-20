import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';

class LockedMedia {
  final String id;
  final String originalPath;
  final String storedPath;
  final String type; // "image" or "video"
  final DateTime lockedAt;

  LockedMedia({
    required this.id,
    required this.originalPath,
    required this.storedPath,
    required this.type,
    required this.lockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalPath': originalPath,
        'storedPath': storedPath,
        'type': type,
        'lockedAt': lockedAt.toIso8601String(),
      };

  static LockedMedia fromJson(Map<String, dynamic> j) => LockedMedia(
        id: j['id'],
        originalPath: j['originalPath'],
        storedPath: j['storedPath'],
        type: j['type'],
        lockedAt: DateTime.parse(j['lockedAt']),
      );
}

class FolderLockerController extends GetxController {
  final RxList<LockedMedia> lockedMedia = <LockedMedia>[].obs;

  late Directory appDocDir;
  final String mediaIndexFileName = 'locked_media.json';

  @override
  void onInit() {
    super.onInit();
    initPaths();
  }

  Future<void> initPaths() async {
    appDocDir = await getApplicationDocumentsDirectory();

    // FolderLocker main folder
    final lockerFolder = Directory('${appDocDir.path}/FolderLocker');
    if (!await lockerFolder.exists()) {
      await lockerFolder.create(recursive: true);
    }

    // LockedMedia subfolder
    final lockedMediaFolder = Directory('${lockerFolder.path}/LockedMedia');
    if (!await lockedMediaFolder.exists()) {
      await lockedMediaFolder.create(recursive: true);

      // .nomedia file to hide from gallery
      final nomedia = File('${lockedMediaFolder.path}/.nomedia');
      if (!await nomedia.exists()) {
        await nomedia.create();
      }
    }

    await loadMediaIndex();
  }

  Future<File> mediaIndexFile() async {
    final f = File('${appDocDir.path}/$mediaIndexFileName');
    if (!await f.exists()) await f.create();
    return f;
  }

  Future<void> loadMediaIndex() async {
    final f = await mediaIndexFile();
    try {
      final text = await f.readAsString();
      if (text.trim().isEmpty) {
        lockedMedia.value = [];
        return;
      }
      final data = jsonDecode(text) as List<dynamic>;
      lockedMedia.value = data.map((e) => LockedMedia.fromJson(e)).toList();
    } catch (_) {
      lockedMedia.value = [];
    }
  }

  Future<void> saveMediaIndex() async {
    final f = await mediaIndexFile();
    final data = lockedMedia.map((e) => e.toJson()).toList();
    await f.writeAsString(jsonEncode(data));
  }

  /// 📂 Pick and Lock Media
  Future<void> pickAndLockMedia({required bool isVideo, bool moveInsteadOfCopy = true}) async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: isVideo ? FileType.video : FileType.image,
      allowMultiple: true,
    );

    if (result == null) return;

    final mediaFiles = result.paths.whereType<String>().map((path) => File(path)).toList();
    final destParent = Directory('${appDocDir.path}/FolderLocker/LockedMedia');

    for (var file in mediaFiles) {
      final fileName = file.uri.pathSegments.last;
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final destFile = File('${destParent.path}/$id\_$fileName');

      try {
        await destFile.writeAsBytes(await file.readAsBytes());

        if (moveInsteadOfCopy && await file.exists()) {
          try {
            await file.delete();
            // 🔥 notify gallery original deleted
            await PhotoManager.editor.deleteWithIds([file.path]);
          } catch (_) {
            Get.snackbar("Warning", "Copied but could not delete original.");
          }
        }

        final locked = LockedMedia(
          id: id,
          originalPath: file.path,
          storedPath: destFile.path,
          type: isVideo ? "video" : "image",
          lockedAt: DateTime.now(),
        );

        lockedMedia.add(locked);
        await saveMediaIndex();
      } catch (e) {
        Get.snackbar("Error", e.toString());
      }
    }

    Get.snackbar("Success", "${isVideo ? "Video(s)" : "Image(s)"} locked securely!");
  }

  /// 🔓 Unlock Media
  Future<void> unlockMedia(LockedMedia media, {bool moveInsteadOfCopy = true}) async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }

    final srcFile = File(media.storedPath);
    if (!await srcFile.exists()) {
      Get.snackbar("Error", "Locked file not found!");
      return;
    }

    final destFile = File(media.originalPath);
    try {
      await destFile.writeAsBytes(await srcFile.readAsBytes());

      if (moveInsteadOfCopy) {
        try {
          await srcFile.delete();
        } catch (_) {}
      }

      // 🔥 notify gallery new file added
      if (media.type == "image") {
        await PhotoManager.editor.saveImageWithPath(destFile.path);
      } else {
        await PhotoManager.editor.saveVideo(destFile);
      }

      lockedMedia.removeWhere((f) => f.id == media.id);
      await saveMediaIndex();

      Get.snackbar("Success", "${media.type} restored!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}

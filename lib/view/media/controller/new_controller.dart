import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:media_scanner/media_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class LockedMedia {
  final String id;
  final String originalPath;
  final String storedPath;
  final String type; // image / video
  final DateTime lockedAt;

  LockedMedia({
    required this.id,
    required this.originalPath,
    required this.storedPath,
    required this.type,
    required this.lockedAt,
  });
}

class LockedFolderMedia {
  final String id;
  final String name; // folder name
  final List<LockedMedia> media; // all media in folder

  LockedFolderMedia({
    required this.id,
    required this.name,
    required this.media,
  });
}

class MediaLockerController extends GetxController {
  RxList<LockedFolderMedia> lockedFolders = <LockedFolderMedia>[].obs;

  /// Pick & Lock media into a specific folder
  Future<void> pickAndLockMedia({required String folderName, bool moveInsteadOfCopy = true}) async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: true,
    );

    if (result == null) return;

    final files = result.paths.whereType<String>().map((path) => File(path)).toList();
    if (files.isEmpty) return;

    // Check if folder already exists
    LockedFolderMedia? folder = lockedFolders.firstWhereOrNull((f) => f.name == folderName);

    final folderId = folder?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final folderDir = Directory("/storage/emulated/0/com.example.folderlockerapp/$folderName-$folderId");

    if (!await folderDir.exists()) await folderDir.create(recursive: true);

    // Hide folder from gallery
    final nomedia = File("${folderDir.path}/.nomedia");
    if (!await nomedia.exists()) await nomedia.create();

    List<LockedMedia> mediaList = folder?.media ?? [];

    for (var file in files) {
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final destFile = File("${folderDir.path}/$id\_${file.uri.pathSegments.last}");

      try {
        await file.copy(destFile.path);

        if (moveInsteadOfCopy) await file.delete();

        mediaList.add(LockedMedia(
          id: id,
          originalPath: file.path,
          storedPath: destFile.path,
          type: file.path.endsWith(".mp4") ? "video" : "image",
          lockedAt: DateTime.now(),
        ));
      } catch (e) {
        Get.snackbar("Error", e.toString());
      }
    }

    if (folder == null) {
      lockedFolders.add(LockedFolderMedia(id: folderId, name: folderName, media: mediaList));
    } else {
      folder.media.addAll(mediaList);
      lockedFolders.refresh();
    }

    Get.snackbar("Success", "Media added to folder '$folderName'!");
  }

  /// Unlock a media item and restore to gallery
  Future<void> unlockMedia(LockedMedia media, {bool moveInsteadOfCopy = true}) async {
    final file = File(media.storedPath);

    if (!await file.exists()) {
      Get.snackbar("Error", "Locked file not found!");
      return;
    }

    final galleryFolder = Directory("/storage/emulated/0/DCIM/MyRestored");
    if (!await galleryFolder.exists()) await galleryFolder.create(recursive: true);

    final restoredFile = File("${galleryFolder.path}/${media.id}_${file.uri.pathSegments.last}");

    try {
      await file.copy(restoredFile.path);

      if (moveInsteadOfCopy) await file.delete();

      MediaScanner.loadMedia(path: restoredFile.path);

      // Remove from folder
      for (var folder in lockedFolders) {
        folder.media.removeWhere((m) => m.id == media.id);
      }

      // Remove empty folders
      lockedFolders.removeWhere((f) => f.media.isEmpty);

      Get.snackbar("Success", "${media.type} restored to gallery!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }
}

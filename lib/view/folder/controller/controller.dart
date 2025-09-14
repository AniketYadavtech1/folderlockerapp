import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class LockedFolder {
  final String id;
  final String originalPath;
  final String storedPath;
  final DateTime lockedAt;

  LockedFolder({
    required this.id,
    required this.originalPath,
    required this.storedPath,
    required this.lockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalPath': originalPath,
        'storedPath': storedPath,
        'lockedAt': lockedAt.toIso8601String(),
      };

  static LockedFolder fromJson(Map<String, dynamic> j) => LockedFolder(
        id: j['id'],
        originalPath: j['originalPath'],
        storedPath: j['storedPath'],
        lockedAt: DateTime.parse(j['lockedAt']),
      );
}

class FolderLockerController extends GetxController {
  final RxList<LockedFolder> lockedFolders = <LockedFolder>[].obs;
  late Directory appDocDir;
  final String indexFileName = 'locked_index.json';

  @override
  void onInit() {
    super.onInit();
    _initPaths();
  }

  Future<void> _initPaths() async {
    appDocDir = await getApplicationDocumentsDirectory();
    await _loadIndex();
  }

  Future<File> _indexFile() async {
    final f = File('${appDocDir.path}/$indexFileName');
    if (!await f.exists()) await f.create();
    return f;
  }

  Future<void> _loadIndex() async {
    final f = await _indexFile();
    try {
      final text = await f.readAsString();
      if (text.trim().isEmpty) {
        lockedFolders.value = [];
        return;
      }
      final data = jsonDecode(text) as List<dynamic>;
      lockedFolders.value = data.map((e) => LockedFolder.fromJson(e)).toList();
    } catch (_) {
      lockedFolders.value = [];
    }
  }

  Future<void> _saveIndex() async {
    final f = await _indexFile();
    final data = lockedFolders.map((e) => e.toJson()).toList();
    await f.writeAsString(jsonEncode(data));
  }

  openPermissionSettings() async {
    // Check if any critical permission is denied
    if (await Permission.storage.isDenied || await Permission.manageExternalStorage.isDenied) {
      // Open app settings
      bool opened = await openAppSettings();

      if (!opened) {
        // Optional: show a message if settings page could not open
        print("Failed to open app settings. Please enable permissions manually.");
      }
    }
  }

  Future<void> pickAndLockFolder({required bool moveInsteadOfCopy}) async {
    // final ok =
    await openPermissionSettings();
    // if (!ok) {
    //   Get.snackbar("Permission Denied", "Storage access is required!");
    //   return;
    // }

    String? selectedDir = await FilePicker.platform.getDirectoryPath();
    if (selectedDir == null) return;

    final srcDir = Directory(selectedDir);
    if (!await srcDir.exists()) {
      Get.snackbar("Error", "Selected folder does not exist.");
      return;
    }

    final folderName =
        srcDir.uri.pathSegments.isNotEmpty ? srcDir.uri.pathSegments.where((s) => s.isNotEmpty).last : 'locked';

    final destParent = Directory('${appDocDir.path}/LockedFolders');
    if (!await destParent.exists()) await destParent.create(recursive: true);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final destDir = Directory('${destParent.path}/$id\_$folderName');

    try {
      await _copyDirectory(srcDir, destDir);

      // hide media
      final nomedia = File('${destDir.path}/.nomedia');
      if (!await nomedia.exists()) await nomedia.create();

      if (moveInsteadOfCopy) {
        try {
          await srcDir.delete(recursive: true);
        } catch (_) {
          Get.snackbar("Warning", "Copied but could not delete original.");
        }
      }

      final lockedFolder = LockedFolder(
        id: id,
        originalPath: selectedDir,
        storedPath: destDir.path,
        lockedAt: DateTime.now(),
      );

      lockedFolders.add(lockedFolder);
      await _saveIndex();
      Get.snackbar("Success", "Folder locked successfully!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> unlockAndRestore(LockedFolder l) async {
    final dest = Directory(l.storedPath);
    if (!await dest.exists()) {
      Get.snackbar("Error", "Stored folder not found.");
      return;
    }

    final origDir = Directory(l.originalPath);
    final origParent = origDir.parent;

    try {
      if (!await origParent.exists()) await origParent.create(recursive: true);
      await _copyDirectory(dest, origDir);

      try {
        await dest.delete(recursive: true);
      } catch (_) {}

      lockedFolders.removeWhere((e) => e.id == l.id);
      await _saveIndex();
      Get.snackbar("Restored", "Folder restored to original location.");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> _copyDirectory(Directory src, Directory dest) async {
    if (!await dest.exists()) await dest.create(recursive: true);

    await for (FileSystemEntity entity in src.list(recursive: false)) {
      final name = entity.uri.pathSegments.last;
      if (entity is File) {
        final newFile = File('${dest.path}/$name');
        await newFile.create(recursive: true);
        await entity.copy(newFile.path);
      } else if (entity is Directory) {
        await _copyDirectory(entity, Directory('${dest.path}/$name'));
      }
    }
  }
}

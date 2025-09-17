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
    initPaths();
  }

  Future<void> initPaths() async {
    appDocDir = await getApplicationDocumentsDirectory();
    await loadIndex();
  }

  Future<File> indexFile() async {
    final f = File('${appDocDir.path}/$indexFileName');
    if (!await f.exists()) await f.create();
    return f;
  }

  Future<void> loadIndex() async {
    final f = await indexFile();
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
    final f = await indexFile();
    final data = lockedFolders.map((e) => e.toJson()).toList();
    await f.writeAsString(jsonEncode(data));
  }

  openPermissionSettings() async {
    if (await Permission.storage.isDenied || await Permission.manageExternalStorage.isDenied) {
      bool opened = await openAppSettings();

      if (!opened) {}
    }
  }

  Future<void> pickAndLockFolder({required bool moveInsteadOfCopy}) async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }

    String? selectedDir = await FilePicker.platform.getDirectoryPath(
      dialogTitle: "Select a folder to lock",
      initialDirectory: "/storage/emulated/0",
    );

    if (selectedDir == null) return;

    final srcDir = Directory(selectedDir);
    if (!await srcDir.exists()) {
      Get.snackbar("Error", "Selected folder does not exist.");
      return;
    }

    final folderName = srcDir.uri.pathSegments.where((s) => s.isNotEmpty).last;

    final appDocDir = await getApplicationDocumentsDirectory();
    final destParent = Directory('${appDocDir.path}/LockedFolders');
    if (!await destParent.exists()) await destParent.create(recursive: true);

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final destDir = Directory('${destParent.path}/$id\_$folderName');

    try {
      await copyDirectory(srcDir, destDir);

      final nomedia = File('${destDir.path}/.nomedia');
      if (!await nomedia.exists()) await nomedia.create();

      if (moveInsteadOfCopy) {
        try {
          await srcDir.delete(recursive: true);
        } catch (_) {
          Get.snackbar("Warning", "Copied but could not delete original.");
        }
      }

      // 7. Save locked folder info
      final lockedFolder = LockedFolder(
        id: id,
        originalPath: selectedDir,
        storedPath: destDir.path,
        lockedAt: DateTime.now(),
      );

      lockedFolders.add(lockedFolder);
      await _saveIndex();

      Get.snackbar("Success", "Folder locked securely!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> unlockFolder(LockedFolder lockedFolder, {bool moveInsteadOfCopy = true}) async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }
    final srcDir = Directory(lockedFolder.storedPath);
    if (!await srcDir.exists()) {
      Get.snackbar("Error", "Locked folder not found in app storage.");
      return;
    }
    //  2. Destination = Original path (where it was before locking)
    final destDir = Directory(lockedFolder.originalPath);
    if (!await destDir.exists()) {
      await destDir.create(recursive: true);
    }
    try {
      //  3. Copy back to original internal storage path
      await copyDirectory(srcDir, destDir, ignoreNomedia: true);

      //  4. If moveInsteadOfCopy = true → delete from app storage
      if (moveInsteadOfCopy) {
        try {
          await srcDir.delete(recursive: true);
        } catch (_) {
          Get.snackbar("Warning", "Restored but could not delete from app storage.");
        }
      }

      //  5. Remove from locked index
      lockedFolders.removeWhere((f) => f.id == lockedFolder.id);
      // await saveIndex();

      Get.snackbar("Success", "Folder restored at: ${lockedFolder.originalPath}");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> copyDirectory(Directory source, Directory destination, {bool ignoreNomedia = false}) async {
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    await for (var entity in source.list(recursive: false)) {
      final name = entity.uri.pathSegments.last;
      // Skip .nomedia file when restoring
      if (ignoreNomedia && name == ".nomedia") continue;
      if (entity is File) {
        File newFile = File("${destination.path}/$name");
        await newFile.writeAsBytes(await entity.readAsBytes());
      } else if (entity is Directory) {
        Directory newSubDir = Directory("${destination.path}/$name");
        await copyDirectory(entity, newSubDir, ignoreNomedia: ignoreNomedia);
      }
    }
  }
}

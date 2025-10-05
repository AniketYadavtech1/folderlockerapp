import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/themes/utill/app_colors.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class FMediaController extends GetxController {
  final ImagePicker picker = ImagePicker();
  late Box box;

  RxList<File> lockedImages = <File>[].obs;
  RxList<Directory> folders = <Directory>[].obs;
  RxList<File> selectedImages = <File>[].obs;
  RxBool load = false.obs;
  RxBool isGridView = false.obs;

  Directory? currentFolder;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box('locked_images');
    loadFolders();
  }

  // 🔹 Toggle list/grid view
  void toggleView() => isGridView.value = !isGridView.value;

  // 🔹 Load all folders
  Future<void> loadFolders() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory("${appDir.path}/LockedFolders");
    if (!dir.existsSync()) dir.createSync(recursive: true);
    folders.value = dir.listSync().whereType<Directory>().toList();
  }

  // 🔹 Create folder
  Future<void> createFolder(String folderName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newFolder = Directory("${appDir.path}/LockedFolders/$folderName");
    if (!newFolder.existsSync()) {
      await newFolder.create(recursive: true);
      folders.add(newFolder);
    }
  }

  // 🔹 Rename folder
  Future<void> renameFolder(Directory folder, String newName) async {
    final newPath = "${folder.parent.path}/$newName";
    final newFolder = await folder.rename(newPath);
    folders[folders.indexOf(folder)] = newFolder;
  }

  // 🔹 Delete folder
  Future<void> deleteFolder(Directory folder) async {
    try {
      if (await folder.exists()) {
        await folder.delete(recursive: true);
        box.delete(folder.path); // also remove from Hive
        folders.remove(folder);
      }
    } catch (e) {
      debugPrint("deleteFolder error: $e");
    }
  }

  // 🔹 Load folder images (from Hive or folder)
  Future<void> loadFolderImages(Directory folder) async {
    currentFolder = folder;

    final storedPaths = box.get(folder.path, defaultValue: <String>[]);
    final existingFiles = storedPaths.map<File>((p) => File(p)).where((f) => f.existsSync()).toList();

    lockedImages.assignAll(existingFiles);
  }

  // 🔹 Pick & lock images
  Future<void> pickImagesToFolder(BuildContext context, Directory folder) async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) return;

    final pickedAssets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: RequestType.image,
        themeColor: AppColors.primary1,
        gridThumbnailSize: const ThumbnailSize(100, 100),
      ),
    );

    if (pickedAssets == null || pickedAssets.isEmpty) return;

    List<String> storedPaths = List<String>.from(box.get(folder.path, defaultValue: []));

    for (final asset in pickedAssets) {
      final file = await asset.file;
      if (file != null) {
        final newPath = "${folder.path}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
        final newFile = await file.copy(newPath);
        lockedImages.add(newFile);
        storedPaths.add(newFile.path);
      }
    }

    // save all image paths permanently in Hive
    await box.put(folder.path, storedPaths);

    // optionally delete from gallery
    final deleted = await PhotoManager.editor.deleteWithIds(pickedAssets.map((e) => e.id).toList());
    debugPrint("Deleted ${deleted.length} from gallery");
  }

  // 🔹 Delete locked image
  Future<void> deleteLockedImage(File file) async {
    if (await file.exists()) await file.delete();
    lockedImages.remove(file);

    // update Hive
    final folderPath = currentFolder?.path;
    if (folderPath != null) {
      List<String> stored = List<String>.from(box.get(folderPath, defaultValue: []));
      stored.remove(file.path);
      await box.put(folderPath, stored);
    }
  }

  // 🔹 Unlock image (restore to gallery)
  Future<void> unlockImage(File lockedFile) async {
    try {
      await PhotoManager.editor.saveImageWithPath(lockedFile.path);
      await deleteLockedImage(lockedFile);
    } catch (e) {
      debugPrint("unlockImage error: $e");
    }
  }

  // 🔹 Selection handling
  void toggleSelection(File file) {
    if (selectedImages.contains(file)) {
      selectedImages.remove(file);
    } else {
      selectedImages.add(file);
    }
  }

  Future<void> deleteSelected() async {
    for (final file in selectedImages) {
      await deleteLockedImage(file);
    }
    selectedImages.clear();
  }

  Future<void> shareSelected() async {
    if (selectedImages.isEmpty) return;
    try {
      final xFiles = selectedImages.map((e) => XFile(e.path)).toList();
      await Share.shareXFiles(xFiles, text: "Check out these images!");
    } catch (e) {
      debugPrint("shareSelected error: $e");
    }
  }
}

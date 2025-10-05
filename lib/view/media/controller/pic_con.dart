import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:folderlockerapp/view/themes/utill/app_colors.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MediaController extends GetxController {
  var lockedImages = <File>[].obs;
  final ImagePicker picker = ImagePicker();
  late Box<String> box;
  RxBool load = false.obs;
  var selectedImages = <File>[].obs;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box<String>('locked_images');
    loadLockedImages();
  }

  void loadLockedImages() {
    load.value = true;
    lockedImages.value = box.values.map((path) => File(path)).toList();
    load.value = false;
  }

  Future<void> pickAndLockFromGallery(BuildContext context) async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) return;
    final List<AssetEntity>? pickedAssets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
          requestType: RequestType.image, themeColor: AppColors.primary1, gridThumbnailSize: ThumbnailSize(100, 100)),
    );
    if (pickedAssets == null || pickedAssets.isEmpty) return;
    for (final asset in pickedAssets) {
      final file = await asset.file;
      if (file != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
        final newFile = await file.copy(newPath);
        await box.put(newPath, newPath);
        lockedImages.add(newFile);
      }
    }
    final deletedList = await PhotoManager.editor.deleteWithIds(pickedAssets.map((a) => a.id).toList());
    debugPrint("Deleted ${deletedList.length} images from gallery.");
  }

  Future<void> deleteFromGallery(File file) async {
    try {
      final entry = box.get(file.path);
      if (entry == null) return;
      final parts = entry.split("|");
      if (parts.length < 2) return;
      final assetId = parts[1];
      final deleted = await PhotoManager.editor.deleteWithIds([assetId]);
      if (deleted.isNotEmpty) {
        debugPrint("Deleted ${deleted.length} item(s) from gallery.");
      } else {
        debugPrint("No matching asset found to delete.");
      }
      await box.delete(file.path);
      lockedImages.remove(file);
    } catch (e) {
      debugPrint("deleteFromGallery error: $e");
    }
  }

  Future<void> unlockImage(File lockedFile) async {
    try {
      final result = await PhotoManager.editor
          .saveImageWithPath(lockedFile.path, title: 'restored_${DateTime.now().millisecondsSinceEpoch}');
      debugPrint("Unlocked to gallery: $result");
      if (await lockedFile.exists()) await lockedFile.delete();
      final key = box.keys.firstWhere((k) => box.get(k) == lockedFile.path, orElse: () => null);
      if (key != null) await box.delete(key);
      lockedImages.remove(lockedFile);
    } catch (e) {
      debugPrint("unlockImage error: $e");
    }
  }

  void swapImages(int oldIndex, int newIndex) {
    final temp = lockedImages[oldIndex];
    lockedImages.removeAt(oldIndex);
    lockedImages.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, temp);
  }

  Future<void> deleteLockedImage(File lockedFile) async {
    try {
      if (await lockedFile.exists()) {
        await lockedFile.delete();
      }
      final key = box.keys.firstWhere((k) => box.get(k) == lockedFile.path, orElse: () => null);
      if (key != null) {
        await box.delete(key);
      }
      lockedImages.remove(lockedFile);
      debugPrint("Deleted locked image: ${lockedFile.path}");
    } catch (e) {
      debugPrint("deleteLockedImage error: $e");
    }
  }

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
      final xFiles = selectedImages.map((file) => XFile(file.path)).toList();
      await Share.shareXFiles(
        xFiles,
        text: 'Check out these images!',
      );
    } catch (e) {
      debugPrint("Error sharing images: $e");
    }
  }

  // folder
  RxBool isGridView = false.obs;

  void toggleView() => isGridView.value = !isGridView.value;

  Future<void> loadFolders() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory("${appDir.path}/LockedFolders");
    if (!directory.existsSync()) {
      directory.createSync(recursive: true);
    }
    folders.value = directory.listSync().whereType<Directory>().toList();
  }

  var folders = <Directory>[].obs;

  Future<void> createFolder(String folderName) async {
    final appDir = await getApplicationDocumentsDirectory();
    final newFolder = Directory("${appDir.path}/LockedFolders/$folderName");
    if (!newFolder.existsSync()) {
      await newFolder.create(recursive: true);
      folders.add(newFolder);
    }
  }

  Future<void> deleteFolder(Directory folder) async {
    try {
      if (await folder.exists()) {
        await folder.delete(recursive: true);
      } else {}
    } catch (e) {}
  }
}

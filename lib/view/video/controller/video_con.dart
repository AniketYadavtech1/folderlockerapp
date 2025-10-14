import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/themes/utill/app_colors.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class VideoMediaController extends GetxController {
  var lockedVideos = <File>[].obs;
  late Box<String> box;
  RxBool load = false.obs;
  var selectedVideos = <File>[].obs;
  RxBool loadAdd = false.obs;

  @override
  void onInit() {
    super.onInit();
    box = Hive.box<String>('locked_videos');
    loadLockedVideos();
  }

  void loadLockedVideos() {
    load.value = true;
    Future.delayed(const Duration(milliseconds: 300), () {
      lockedVideos.value = box.values.map((path) => File(path)).toList();
      load.value = false;
    });
  }

  Future<void> pickAndLockFromGallery(BuildContext context) async {
    try {
      final permitted = await PhotoManager.requestPermissionExtend();
      if (!permitted.isAuth) return;

      final List<AssetEntity>? pickedAssets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          requestType: RequestType.video,
          themeColor: AppColors.primary1,
          gridThumbnailSize: const ThumbnailSize(120, 120),
          maxAssets: 1000,
        ),
      );

      if (pickedAssets == null || pickedAssets.isEmpty) return;

      loadAdd.value = true;
      for (final asset in pickedAssets) {
        final file = await asset.file;
        if (file != null) {
          final appDir = await getApplicationDocumentsDirectory();
          final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
          final newFile = await file.copy(newPath);

          await box.put(newPath, newPath);
          lockedVideos.add(newFile);
        }
      }
      await PhotoManager.editor.deleteWithIds(
        pickedAssets.map((a) => a.id).toList(),
      );

      loadAdd.value = false;
    } catch (e) {
      debugPrint("pickAndLockFromGallery error: $e");
      loadAdd.value = false;
    }
  }

  Future<void> unlockVideo(File lockedFile) async {
    try {
      final result = await PhotoManager.editor.saveVideo(
        File(lockedFile.path),
        title: 'restored_${DateTime.now().millisecondsSinceEpoch}',
      );
      debugPrint("Unlocked to gallery: $result");

      if (await lockedFile.exists()) await lockedFile.delete();

      final key = box.keys.firstWhere(
        (k) => box.get(k) == lockedFile.path,
        orElse: () => null,
      );
      if (key != null) await box.delete(key);

      lockedVideos.remove(lockedFile);
    } catch (e) {
      debugPrint("unlockVideo error: $e");
    }
  }

  Future<void> deleteLockedVideo(File lockedFile) async {
    try {
      if (await lockedFile.exists()) await lockedFile.delete();

      final key = box.keys.firstWhere(
        (k) => box.get(k) == lockedFile.path,
        orElse: () => null,
      );
      if (key != null) await box.delete(key);

      lockedVideos.remove(lockedFile);
    } catch (e) {}
  }

  void toggleSelection(File file) {
    if (selectedVideos.contains(file)) {
      selectedVideos.remove(file);
    } else {
      selectedVideos.add(file);
    }
  }

  Future<void> deleteSelected() async {
    for (final file in selectedVideos) {
      await deleteLockedVideo(file);
    }
    selectedVideos.clear();
  }

  void selectAllVideos() {
    selectedVideos.assignAll(lockedVideos);
  }

  void clearSelection() {
    selectedVideos.clear();
  }

  RxBool isGridView = false.obs;
  void toggleView() => isGridView.value = !isGridView.value;
}

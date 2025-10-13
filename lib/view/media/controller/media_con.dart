import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:folderlockerapp/view/themes/utill/app_colors.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MediaController extends GetxController {
  var lockedImages = <File>[].obs;
  final ImagePicker picker = ImagePicker();
  late Box<String> box;

  RxBool load = false.obs;
  RxBool isPaginating = false.obs;
  RxBool hasMore = true.obs;
  int pageSize = 10;
  int currentPage = 0;

  var visibleImages = <File>[].obs; // For pagination
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
    _loadInitialPage();
    load.value = false;
  }

  void _loadInitialPage() {
    visibleImages.clear();
    currentPage = 0;
    hasMore.value = lockedImages.length > pageSize;
    _loadNextPage();
  }

  void _loadNextPage() {
    if (!hasMore.value || isPaginating.value) return;
    isPaginating.value = true;

    final startIndex = currentPage * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, lockedImages.length);
    final newItems = lockedImages.sublist(startIndex, endIndex);
    visibleImages.addAll(newItems);

    currentPage++;
    hasMore.value = visibleImages.length < lockedImages.length;
    isPaginating.value = false;
  }

  Future<void> pickAndLockFromGallery(BuildContext context) async {
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) return;

    final List<AssetEntity>? pickedAssets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        requestType: RequestType.image,
        themeColor: AppColors.primary1,
        gridThumbnailSize: const ThumbnailSize(100, 100),
      ),
    );

    if (pickedAssets == null || pickedAssets.isEmpty) return;

    for (final asset in pickedAssets) {
      final file = await asset.file;
      if (file != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
        final newFile = await file.copy(newPath);
        await box.put(newPath, newPath);
        lockedImages.insert(0, newFile);
      }
    }

    final deletedList = await PhotoManager.editor.deleteWithIds(pickedAssets.map((a) => a.id).toList());
    debugPrint("Deleted ${deletedList.length} images from gallery.");

    _loadInitialPage();
  }

  Future<void> unlockImage(File lockedFile) async {
    try {
      final result = await PhotoManager.editor.saveImageWithPath(
        lockedFile.path,
        title: 'restored_${DateTime.now().millisecondsSinceEpoch}',
      );
      debugPrint("Unlocked to gallery: $result");
      if (await lockedFile.exists()) await lockedFile.delete();

      final key = box.keys.firstWhere((k) => box.get(k) == lockedFile.path, orElse: () => null);
      if (key != null) await box.delete(key);
      lockedImages.remove(lockedFile);
      visibleImages.remove(lockedFile);
    } catch (e) {
      debugPrint("unlockImage error: $e");
    }
  }

  Future<void> deleteLockedImage(File lockedFile) async {
    try {
      if (await lockedFile.exists()) await lockedFile.delete();
      final key = box.keys.firstWhere((k) => box.get(k) == lockedFile.path, orElse: () => null);
      if (key != null) await box.delete(key);
      lockedImages.remove(lockedFile);
      visibleImages.remove(lockedFile);
      debugPrint("Deleted locked image: ${lockedFile.path}");
    } catch (e) {
      debugPrint("deleteLockedImage error: $e");
    }
  }

  void toggleSelection(File file) {
    selectedImages.contains(file) ? selectedImages.remove(file) : selectedImages.add(file);
  }

  Future<void> deleteSelected() async {
    for (final file in selectedImages) {
      await deleteLockedImage(file);
    }
    selectedImages.clear();
  }

  void selectAllImages() => selectedImages.assignAll(lockedImages);
  void clearSelection() => selectedImages.clear();

  RxBool isGridView = false.obs;
  void toggleViewMode() => isGridView.value = !isGridView.value;

  // Pagination trigger
  void onScroll(ScrollController controller) {
    if (controller.position.pixels >= controller.position.maxScrollExtent - 200) {
      _loadNextPage();
    }
  }
}

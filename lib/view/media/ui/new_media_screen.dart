import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class GalleryDeleteScreen extends StatefulWidget {
  const GalleryDeleteScreen({super.key});

  @override
  State<GalleryDeleteScreen> createState() => _GalleryDeleteScreenState();
}

class _GalleryDeleteScreenState extends State<GalleryDeleteScreen> {
  final RxList<AssetEntity> galleryImages = <AssetEntity>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    loadGalleryImages();
  }

  /// 🔹 Load all gallery images
  Future<void> loadGalleryImages() async {
    isLoading.value = true;
    final permitted = await PhotoManager.requestPermissionExtend();
    if (!permitted.isAuth) {
      isLoading.value = false;
      Get.snackbar("Permission Denied", "Please grant gallery access.");
      return;
    }

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(onlyAll: true);
    if (paths.isNotEmpty) {
      final List<AssetEntity> assets = await paths.first.getAssetListRange(start: 0, end: 1000);
      galleryImages.assignAll(assets);
    }

    isLoading.value = false;
  }

  /// 🔹 Delete selected image with confirmation
  Future<void> deleteImageWithConfirmation(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Image"),
        content: const Text("Are you sure you want to delete this image?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes, Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await PhotoManager.editor.deleteWithIds([asset.id]);
      if (deleted.isNotEmpty) {
        galleryImages.remove(asset);
        Get.snackbar("Deleted", "Image deleted successfully!",
            snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      } else {
        Get.snackbar("Failed", "Unable to delete image.", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  /// 🔹 Full screen preview
  void openPreview(AssetEntity asset) async {
    final file = await asset.file;
    if (file == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullPreviewScreen(imageFile: file),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Gallery Images"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            onPressed: loadGalleryImages,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (galleryImages.isEmpty) {
          return const Center(
            child: Text(
              "No images found",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: galleryImages.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final asset = galleryImages[index];
            return FutureBuilder<File?>(
              future: asset.file,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 1.5),
                  );
                }
                final file = snapshot.data!;
                return Stack(
                  children: [
                    InkWell(
                      onTap: () => openPreview(asset),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () => deleteImageWithConfirmation(asset),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      }),
    );
  }
}

/// 🔍 Full-screen preview with zoom support
class FullPreviewScreen extends StatelessWidget {
  final File imageFile;
  const FullPreviewScreen({super.key, required this.imageFile});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Preview"),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.file(imageFile, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

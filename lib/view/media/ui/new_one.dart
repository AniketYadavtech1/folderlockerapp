import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/pic_con.dart';
import 'package:folderlockerapp/view/media/ui/image_preview.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

class MediaScreenViewone extends StatelessWidget {
  const MediaScreenViewone({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(MediaController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locked Images'),
        actions: [
          Obx(() {
            if (con.lockedImages.isNotEmpty) {
              return Row(
                children: [
                  Obx(() => Checkbox(
                        value: con.selectedImages.length == con.lockedImages.length && con.lockedImages.isNotEmpty,
                        onChanged: (value) {
                          if (value == true) {
                            con.selectAllImages();
                          } else {
                            con.clearSelection();
                          }
                        },
                      )),
                  const SizedBox(width: 8),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SafeArea(
        child: Obx(() {
          if (con.lockedImages.isEmpty) {
            return const Center(child: Text("No locked images found."));
          }
          return SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(con.lockedImages.length, (index) {
                final image = con.lockedImages[index];
                final isSelected = con.selectedImages.contains(image);

                return GestureDetector(
                  onLongPress: () {
                    if (con.selectedImages.isEmpty) con.toggleSelection(image);
                  },
                  onTap: () {
                    if (con.selectedImages.isNotEmpty) {
                      con.toggleSelection(image);
                    } else {
                      final allImages = List<File>.from(con.lockedImages);
                      final initialIndex = allImages.indexOf(image);
                      Get.to(() => ImagePreviewScreen(
                            allImages: allImages,
                            initialIndex: initialIndex,
                          ));
                    }
                  },
                  child: Stack(
                    children: [
                      Image.file(
                        image,
                        width: MediaQuery.sizeOf(context).width * 0.45,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      if (isSelected)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black54,
                            child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 40),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          );
        }),
      ),
      floatingActionButton: Obx(() {
        if (con.selectedImages.isEmpty) {
          return FloatingActionButton(
            onPressed: () => con.pickAndLockFromGallery(context),
            child: const Icon(Icons.add),
          );
        }

        // Selection active: show action buttons
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(blurRadius: 5, color: Colors.black26)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unlock
              IconButton(
                  icon: const Icon(Icons.lock_open, color: Colors.green),
                  onPressed: () {
                    for (final img in con.selectedImages) {
                      con.unlockImage(img);
                    }
                    con.selectedImages.clear();
                  }),
              // Delete from Hive/app only
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: con.deleteSelected),
              // Share
              IconButton(icon: const Icon(Icons.share, color: Colors.blue), onPressed: con.shareSelected),
              // Delete from Gallery button
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.purple),
                tooltip: "Delete from Gallery",
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Delete from Gallery"),
                      content: const Text("Are you sure you want to delete selected images from your gallery?"),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                      ],
                    ),
                  );
                  if (confirm != true) return;

                  // Delete each image using PhotoManager
                  for (final img in con.selectedImages) {
                    final key = con.lockedImages.indexOf(img);
                    if (key != -1) {
                      try {
                        // Delete from system gallery
                        await PhotoManager.editor.deleteWithIds([con.lockedImages[key].path]);
                        // Remove from Hive
                        await con.box.delete(con.lockedImages[key].path);
                        con.lockedImages.removeAt(key);
                      } catch (e) {
                        debugPrint("Error deleting from gallery: $e");
                      }
                    }
                  }
                  con.selectedImages.clear();
                  Get.snackbar("Deleted", "Images deleted from gallery", snackPosition: SnackPosition.BOTTOM);
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}

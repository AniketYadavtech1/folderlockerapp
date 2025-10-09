import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/pic_con.dart';
import 'package:folderlockerapp/view/media/ui/image_preview.dart';
import 'package:get/get.dart';

class NewMediaScreenView extends StatelessWidget {
  const NewMediaScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(MediaController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locked Images'),
        actions: [
          // 🔘 Toggle Grid/List button
          Obx(() => IconButton(
                icon: Icon(con.isGridView.value ? Icons.view_list : Icons.grid_view),
                onPressed: con.toggleViewMode,
              )),

          // ✅ Select All Checkbox
          Obx(() {
            if (con.lockedImages.isNotEmpty) {
              return Row(
                children: [
                  Checkbox(
                    value: con.selectedImages.length == con.lockedImages.length && con.lockedImages.isNotEmpty,
                    onChanged: (value) {
                      if (value == true) {
                        con.selectAllImages();
                      } else {
                        con.clearSelection();
                      }
                    },
                  ),
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

          // 🔄 Switch between Grid and List view dynamically
          return con.isGridView.value
              ? GridView(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  children: List.generate(con.lockedImages.length, (index) {
                    final image = con.lockedImages[index];
                    final isSelected = con.selectedImages.contains(image);
                    return GestureDetector(
                      onLongPress: () {
                        if (con.selectedImages.isEmpty) {
                          con.toggleSelection(image);
                        }
                      },
                      onTap: () {
                        if (con.selectedImages.isNotEmpty) {
                          con.toggleSelection(image);
                        } else {
                          final allImages = List<File>.from(con.lockedImages);
                          final index = allImages.indexOf(image);
                          Get.to(() => ImagePreviewScreen(
                                allImages: allImages,
                                initialIndex: index,
                              ));
                        }
                      },
                      child: Stack(
                        children: [
                          Image.file(
                            image,
                            width: double.infinity,
                            height: double.infinity,
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
                )
              : ListView.builder(
                  itemCount: con.lockedImages.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final image = con.lockedImages[index];
                    final isSelected = con.selectedImages.contains(image);
                    return GestureDetector(
                      onLongPress: () {
                        if (con.selectedImages.isEmpty) {
                          con.toggleSelection(image);
                        }
                      },
                      onTap: () {
                        if (con.selectedImages.isNotEmpty) {
                          con.toggleSelection(image);
                        } else {
                          final allImages = List<File>.from(con.lockedImages);
                          final index = allImages.indexOf(image);
                          Get.to(() => ImagePreviewScreen(
                                allImages: allImages,
                                initialIndex: index,
                              ));
                        }
                      },
                      child: Stack(
                        children: [
                          Card(
                            clipBehavior: Clip.hardEdge,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Image.file(
                              image,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
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
                  },
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
              IconButton(
                icon: const Icon(Icons.lock_open, color: Colors.green),
                onPressed: () {
                  for (final img in con.selectedImages) {
                    con.unlockImage(img);
                  }
                  con.selectedImages.clear();
                },
              ),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: con.deleteSelected),
            ],
          ),
        );
      }),
    );
  }
}

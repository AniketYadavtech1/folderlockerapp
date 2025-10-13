import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/auth/ui/side_drower.dart';
import 'package:folderlockerapp/view/media/controller/media_con.dart';
import 'package:folderlockerapp/view/media/ui/image_preview.dart';
import 'package:folderlockerapp/view/themes/controller/theme_controller.dart';
import 'package:folderlockerapp/view/themes/utill/app_colors.dart';
import 'package:folderlockerapp/view/themes/utill/app_texts.dart';
import 'package:get/get.dart';

class MediaScreenView extends StatelessWidget {
  const MediaScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(MediaController());
    final themCon = Get.find<ThemeController>();
    final scrollController = ScrollController();

    scrollController.addListener(() => con.onScroll(scrollController));

    return Scaffold(
      backgroundColor: AppColors.isDarkMode ? AppColors.transparent : AppColors.white,
      appBar: AppBar(
        title: Text("New Media", style: AppTextStyles.kBody17SemiBoldTextStyle),
        backgroundColor: AppColors.isDarkMode ? AppColors.transparent : AppColors.white,
        actions: [
          // Theme toggle
          Obx(() => CupertinoSwitch(
                value: themCon.isDarkMode.value,
                activeTrackColor: const Color(0xff78C841),
                inactiveTrackColor: const Color(0xffFF4646),
                onChanged: (v) => themCon.toggleTheme(),
              )),
          // Grid/List toggle
          Obx(() => IconButton(
                icon: Icon(con.isGridView.value ? Icons.view_list : Icons.grid_view),
                onPressed: con.toggleViewMode,
              )),
          // Select all checkbox
          Obx(() {
            if (con.lockedImages.isNotEmpty) {
              return Checkbox(
                value: con.selectedImages.length == con.lockedImages.length && con.lockedImages.isNotEmpty,
                onChanged: (value) => value == true ? con.selectAllImages() : con.clearSelection(),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      drawer: const DrawerScreen(),
      body: SafeArea(
        child: Obx(() {
          if (con.load.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (con.visibleImages.isEmpty) {
            return const Center(child: Text("No locked images found."));
          }

          return con.isGridView.value
              ? GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: con.visibleImages.length + (con.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == con.visibleImages.length) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    final image = con.visibleImages[index];
                    final isSelected = con.selectedImages.contains(image);
                    return _buildImageItem(con, image, isSelected);
                  },
                )
              : ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(8),
                  itemCount: con.visibleImages.length + (con.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == con.visibleImages.length) {
                      return const Center(child: CupertinoActivityIndicator());
                    }
                    final image = con.visibleImages[index];
                    final isSelected = con.selectedImages.contains(image);
                    return _buildImageItem(con, image, isSelected);
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
        return _buildActionButtons(con);
      }),
    );
  }

  Widget _buildImageItem(MediaController con, File image, bool isSelected) {
    return GestureDetector(
      onLongPress: () {
        if (con.selectedImages.isEmpty) con.toggleSelection(image);
      },
      onTap: () {
        if (con.selectedImages.isNotEmpty) {
          con.toggleSelection(image);
        } else {
          final allImages = List<File>.from(con.lockedImages);
          final index = allImages.indexOf(image);
          Get.to(() => ImagePreviewScreen(allImages: allImages, initialIndex: index));
        }
      },
      child: Stack(
        children: [
          Image.file(image, width: double.infinity, height: 200, fit: BoxFit.cover),
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
  }

  Widget _buildActionButtons(MediaController con) {
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
            onPressed: () async {
              for (final img in con.selectedImages) {
                await con.unlockImage(img);
              }
              con.selectedImages.clear();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: con.deleteSelected,
          ),
        ],
      ),
    );
  }
}

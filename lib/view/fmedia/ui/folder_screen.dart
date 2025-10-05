import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/fmedia/controller/folder_vicecontroller.dart';
import 'package:get/get.dart';

class FolderDetailScreen extends StatelessWidget {
  final Directory folder;
  const FolderDetailScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(FMediaController());

    return Scaffold(
      appBar: AppBar(title: Text(folder.path.split('/').last)),
      body: Obx(() {
        if (con.lockedImages.isEmpty) {
          return const Center(child: Text("No images in this folder."));
        }
        return SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(con.lockedImages.length, (i) {
              final img = con.lockedImages[i];
              final selected = con.selectedImages.contains(img);
              return GestureDetector(
                onLongPress: () => con.toggleSelection(img),
                onTap: () {
                  if (con.selectedImages.isNotEmpty) con.toggleSelection(img);
                },
                child: Stack(
                  children: [
                    Image.file(
                      img,
                      width: MediaQuery.sizeOf(context).width * 0.45,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    if (selected)
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
      floatingActionButton: Obx(() {
        if (con.selectedImages.isEmpty) {
          return FloatingActionButton(
            onPressed: () => con.pickImagesToFolder(context, folder),
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
                  }),
              IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: con.deleteSelected),
              IconButton(icon: const Icon(Icons.share, color: Colors.blue), onPressed: con.shareSelected),
            ],
          ),
        );
      }),
    );
  }
}

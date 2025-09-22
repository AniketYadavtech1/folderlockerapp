import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/new_controller.dart';
import 'package:get/get.dart';

class MediaLockerScreenss extends StatefulWidget {
  const MediaLockerScreenss({super.key});

  @override
  State<MediaLockerScreenss> createState() => _MediaLockerScreenssState();
}

class _MediaLockerScreenssState extends State<MediaLockerScreenss> {
  final controller = Get.put(MediaLockerController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Media Locker")),
      body: Obx(() {
        if (controller.lockedFolders.isEmpty) {
          return const Center(child: Text("No locked folders"));
        }
        return ListView.builder(
          itemCount: controller.lockedFolders.length,
          itemBuilder: (context, index) {
            final folder = controller.lockedFolders[index];
            return ListTile(
              leading: const Icon(Icons.folder),
              title: Text(folder.name),
              subtitle: Text("${folder.media.length} items"),
              onTap: () {
                Get.to(() => FolderDetailScreen(folder: folder));
              },
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Ask user for folder name
          String folderName = "MyFolder";
          await controller.pickAndLockMedia(folderName: folderName);
        },
        label: const Text("Add Media"),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class FolderDetailScreen extends StatelessWidget {
  final LockedFolderMedia folder;
  final controller = Get.find<MediaLockerController>();

  FolderDetailScreen({required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(folder.name)),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemCount: folder.media.length,
        itemBuilder: (context, index) {
          final media = folder.media[index];
          return GestureDetector(
            onTap: () => controller.unlockMedia(media),
            child: media.type == "image"
                ? Image.file(File(media.storedPath), fit: BoxFit.cover)
                : const Icon(Icons.video_file, size: 50),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/controller.dart';
import 'package:get/get.dart';

class MediaLockerScreen extends StatelessWidget {
  final controller = Get.put(FolderLockerController());

  MediaLockerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Media Locker")),
      body: Obx(() {
        if (controller.lockedMedia.isEmpty) {
          return const Center(child: Text("No hidden media"));
        }
        return ListView.builder(
          itemCount: controller.lockedMedia.length,
          itemBuilder: (context, index) {
            final media = controller.lockedMedia[index];
            return ListTile(
              leading: Icon(media.type == "image" ? Icons.image : Icons.video_file),
              title: Text(media.originalPath.split('/').last),
              subtitle: Text(media.lockedAt.toString()),
              trailing: IconButton(
                icon: const Icon(Icons.lock_open),
                onPressed: () => controller.unlockMedia(media),
              ),
            );
          },
        );
      }),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            heroTag: "hideImage",
            onPressed: () => controller.pickAndLockMedia(isVideo: false),
            label: const Text("Hide Image"),
            icon: const Icon(Icons.image),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: "hideVideo",
            onPressed: () => controller.pickAndLockMedia(isVideo: true),
            label: const Text("Hide Video"),
            icon: const Icon(Icons.video_file),
          ),
        ],
      ),
    );
  }
}

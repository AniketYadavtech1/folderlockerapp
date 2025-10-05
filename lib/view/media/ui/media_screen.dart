import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/pic_con.dart';
import 'package:get/get.dart';

class MediaScreenView extends StatelessWidget {
  const MediaScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(MediaController());
    return Scaffold(
      appBar: AppBar(title: const Text('Locked Images')),
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
                  onLongPress: () => con.toggleSelection(image),
                  onTap: () {
                    if (con.selectedImages.isNotEmpty) {
                      con.toggleSelection(image);
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

        // Show options when selection active
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

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/fmedia/ui/folder_screen.dart';
import 'package:folderlockerapp/view/media/controller/pic_con.dart';
import 'package:get/get.dart';

class FolderListScreen extends StatelessWidget {
  const FolderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final con = Get.put(MediaController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Get.defaultDialog(
                title: "Create Folder",
                content: TextField(
                  decoration: const InputDecoration(hintText: "Folder name"),
                  onSubmitted: (name) {
                    if (name.trim().isNotEmpty) {
                      con.createFolder(name.trim());
                      Get.back();
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (con.folders.isEmpty) {
          return const Center(child: Text("No folders found."));
        }
        return ListView.builder(
          itemCount: con.folders.length,
          itemBuilder: (_, i) {
            final folder = con.folders[i];
            return ListTile(
              title: Text(folder.path.split('/').last),
              leading: const Icon(Icons.folder),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => con.deleteFolder(folder),
              ),
              onTap: () async {
                await con.loadFolders();
                Get.to(() => FolderDetailScreen(folder: folder));
              },
            );
          },
        );
      }),
    );
  }
}

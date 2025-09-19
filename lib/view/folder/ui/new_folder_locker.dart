import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/controller.dart';
import 'folder_content.dart';

class NewLockedFoldersScreen extends StatelessWidget {
  const NewLockedFoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FolderLockerController());

    return Scaffold(
      appBar: AppBar(title: const Text("Folder Locker")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.move_to_inbox),
                  label: const Text("Pick & Move"),
                  onPressed: () => controller.pickAndLockFolder(
                    moveInsteadOfCopy: true,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: Obx(() {
              if (controller.lockedFolders.isEmpty) {
                return const Center(child: Text("No locked folders yet."));
              }
              return ListView.builder(
                itemCount: controller.lockedFolders.length,
                itemBuilder: (_, i) {
                  final l = controller.lockedFolders[i];
                  return Card(
                    child: ListTile(
                      title: Text(l.originalPath.split('/').last),
                      subtitle: Text(
                        "Locked at: ${l.lockedAt.toLocal()}\nStored: ${l.storedPath}",
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.folder_open),
                            tooltip: "Open Folder",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => FolderContentScreen(folder: l),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.lock_open),
                            tooltip: "Unlock Folder",
                            onPressed: () => controller.unlockFolder(l),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

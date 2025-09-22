import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/folder/controller/controller.dart';
import 'package:folderlockerapp/view/themes/newutill/ui/theme_setting_page.dart';
import 'package:get/get.dart';

class LockedFoldersScreen extends StatelessWidget {
  const LockedFoldersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FolderLockers());

    return Scaffold(
      appBar: AppBar(title: const Text("Folder Locker")),
      body: Column(
        children: [
          TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ThemeSettingsScreen()));
              },
              child: Text("setting")),
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
                      subtitle: Text("Locked at: ${l.lockedAt.toLocal().toString()}\nStored: ${l.storedPath}"),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.lock_open),
                        onPressed: () => controller.unlockFolder(l),
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

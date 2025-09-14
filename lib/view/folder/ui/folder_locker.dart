import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/folder/controller/controller.dart';
import 'package:get/get.dart';

class LockedFoldersScreen extends StatefulWidget {
  const LockedFoldersScreen({super.key});

  @override
  State<LockedFoldersScreen> createState() => _LockedFoldersScreenState();
}

class _LockedFoldersScreenState extends State<LockedFoldersScreen> {
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
                  icon: const Icon(Icons.copy),
                  label: const Text("Pick & Copy"),
                  onPressed: () => controller.pickAndLockFolder(
                    moveInsteadOfCopy: false,
                  ),
                ),
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
                        onPressed: () => controller.unlockAndRestore(l),
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

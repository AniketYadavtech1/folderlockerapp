import 'dart:io';

import 'package:flutter/material.dart';

import '../controller/controller.dart';
import 'file_view.dart';

// class FolderContentScreen extends StatelessWidget {
//   final LockedFolder folder;
//   final FolderLockerController controller = Get.find();
//
//   FolderContentScreen({super.key, required this.folder});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text(folder.originalPath.split('/').last)),
//       body: FutureBuilder<List<FileSystemEntity>>(
//         future: controller.openLockedFolder(folder),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text("No files inside this folder."));
//           }
//
//           final items = snapshot.data!;
//           final fileCount = items.whereType<File>().length;
//           final folderCount = items.whereType<Directory>().length;
//
//           return Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // 🔢 Count info
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Text(
//                   " $folderCount folders • 📄 $fileCount files",
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//               ),
//               const Divider(),
//
//               // 📜 List of files/folders
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: items.length,
//                   itemBuilder: (context, index) {
//                     final entity = items[index];
//                     final name = entity.path.split('/').last;
//                     final isDir = entity is Directory;
//
//                     return ListTile(
//                       leading: Icon(isDir ? Icons.folder : Icons.insert_drive_file),
//                       title: Text(name),
//                       subtitle: Text(entity.path),
//                       onTap: () {
//                         if (isDir) {
//                           // Open subfolder inside app
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => FolderContentScreen(
//                                 folder: LockedFolder(
//                                   id: folder.id,
//                                   originalPath: folder.originalPath,
//                                   storedPath: entity.path,
//                                   lockedAt: folder.lockedAt,
//                                 ),
//                               ),
//                             ),
//                           );
//                         } else {
//                           Get.snackbar("File", "Tapped on file: $name");
//                         }
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

class FolderContentScreen extends StatelessWidget {
  final LockedFolder folder;
  const FolderContentScreen({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final dir = Directory(folder.storedPath);

    if (!dir.existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text(folder.originalPath.split('/').last)),
        body: const Center(child: Text("Folder not found!")),
      );
    }

    final files = dir.listSync(recursive: false, followLinks: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Files in ${folder.originalPath.split('/').last}"),
      ),
      body: files.isEmpty
          ? const Center(child: Text("No files inside this folder."))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (_, i) {
                final file = files[i];
                final name = file.path.split('/').last;

                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(name),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FileViewScreen(file: file),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

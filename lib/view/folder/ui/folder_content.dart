import 'dart:io';

import 'package:flutter/material.dart';

import '../controller/controller.dart';
import 'file_view.dart';

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

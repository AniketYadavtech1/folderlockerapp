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
          : GridView.builder(
              shrinkWrap: true,
              itemCount: files.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemBuilder: (_, i) {
                final file = files[i];
                final name = file.path.split('/').last;
                if (name == ".nomedia") {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FileViewScreen(file: file),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            name.isEmpty
                                ? const Icon(Icons.error, color: Colors.grey, size: 30)
                                : const Icon(Icons.picture_as_pdf, color: Colors.red, size: 30),
                            const SizedBox(height: 10),
                            Text(
                              name.isEmpty ? "No file available" : name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

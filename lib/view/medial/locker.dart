import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import 'db.dart';
import 'file_storage.dart';

class LockerDemoScreen extends StatefulWidget {
  const LockerDemoScreen({super.key});

  @override
  State<LockerDemoScreen> createState() => _LockerDemoScreenState();
}

class _LockerDemoScreenState extends State<LockerDemoScreen> {
  List<Map<String, dynamic>> files = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  Future<void> loadFiles() async {
    final allFiles = await DBHelper.getAllFiles();
    files = allFiles.where((file) => file['status'] == 'locked').toList();
    setState(() {});
  }

  Future<void> pickAndLockFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      final file = File(result.files.single.path!);
      await FileStorageHelper.lockFile(file);
      setState(() {});
      loadFiles();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File Locked!")),
      );
    }
  }

  Future<void> unlockFile(Map<String, dynamic> file) async {
    final isIOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    await FileStorageHelper.unlockFile(
      file['id'],
      file['lockedPath'],
      file['originalPath'],
      isIOS: isIOS,
      isAndroid: isAndroid,
    );

    files.removeWhere((element) => element['id'] == file['id']);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("File Unlocked!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Folder Locker")),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndLockFile,
        child: const Icon(Icons.add),
      ),
      body: files.isEmpty
          ? const Center(child: Text("No files locked"))
          : ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                final lockedFile = File(file['lockedPath']);
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: lockedFile.existsSync()
                        ? Image.file(
                            lockedFile,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image_not_supported, size: 50),
                    title: Text(file['fileName']),
                    subtitle: Text(file['status']),
                    trailing: IconButton(
                      icon: const Icon(Icons.lock_open),
                      onPressed: () => unlockFile(file),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'database.dart';

class SecureImageVault extends StatefulWidget {
  const SecureImageVault({super.key});

  @override
  State<SecureImageVault> createState() => _SecureImageVaultState();
}

class _SecureImageVaultState extends State<SecureImageVault> {
  List<File> lockedImages = [];

  @override
  void initState() {
    super.initState();
    loadLockedImages();
  }

  Future<void> loadLockedImages() async {
    final data = await DBHelper.getImages();
    setState(() {
      lockedImages = data.map((e) => File(e["path"])).toList();
    });
  }

  // Lock Image
  Future<void> pickAndLockImage() async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      File pickedFile = File(result.files.single.path!);
      // App-private storage
      final appDir = await getApplicationDocumentsDirectory();
      final newPath = '${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
      // Copy to vault
      final newFile = await pickedFile.copy(newPath);
      // Delete from gallery
      await pickedFile.delete();
      // Save path in DB
      await DBHelper.insertImage(newFile.path);
      setState(() {
        lockedImages.add(newFile);
      });
      debugPrint("Locked: ${newFile.path}");
    }
  }

  // Unlock Image
  Future<void> unlockImage(File lockedFile) async {
    final picturesDir = Directory('/storage/emulated/0/Pictures');
    if (!picturesDir.existsSync()) {
      picturesDir.createSync(recursive: true);
    }
    final restoredPath = '${picturesDir.path}/restored_${DateTime.now().millisecondsSinceEpoch}.png';
    final restoredFile = await lockedFile.copy(restoredPath);
    // Delete from vault
    await lockedFile.delete();
    // Remove from DB
    await DBHelper.deleteImage(lockedFile.path);
    setState(() {
      lockedImages.remove(lockedFile);
    });
    debugPrint("🔓 Restored: ${restoredFile.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Secure Vault (SQLite + FilePicker)")),
      body: lockedImages.isEmpty
          ? const Center(child: Text("No images locked yet"))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: lockedImages.length,
              itemBuilder: (context, index) {
                final file = lockedImages[index];
                return GestureDetector(
                  onLongPress: () => unlockImage(file), // Unlock on long press
                  child: Image.file(file, fit: BoxFit.cover),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndLockImage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

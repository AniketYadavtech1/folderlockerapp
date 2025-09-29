import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sqflite/sqflite.dart';

// ================== DATABASE ==================
class DBHelper {
  static Database? _db;

  static Future<void> initDB() async {
    final dbPath = await getDatabasesPath();
    _db = await openDatabase(
      join(dbPath, "locker.db"),
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE images(id INTEGER PRIMARY KEY AUTOINCREMENT, path TEXT)",
        );
      },
    );
  }

  static Future<int> insertImage(String path) async {
    return await _db!.insert("images", {"path": path});
  }

  static Future<List<Map<String, dynamic>>> getImages() async {
    return await _db!.query("images");
  }

  static Future<int> deleteImage(int id) async {
    return await _db!.delete("images", where: "id=?", whereArgs: [id]);
  }
}

// ================== LOCKER SCREEN ==================
class HiddenImage1View extends StatefulWidget {
  const HiddenImage1View({super.key});

  @override
  State<HiddenImage1View> createState() => _HiddenImage1ViewState();
}

class _HiddenImage1ViewState extends State<HiddenImage1View> {
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _images = [];

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    final data = await DBHelper.getImages();
    setState(() {
      _images = data;
    });
  }

  Future<void> _pickAndLockImages() async {
    try {
      // Request storage/gallery permission
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();
      }

      final pickedFiles = await _picker.pickMultiImage();
      if (pickedFiles.isEmpty) return;

      final appDir = await getApplicationDocumentsDirectory();

      for (var picked in pickedFiles) {
        final file = File(picked.path);

        // Copy to app private folder
        final newPath = "${appDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
        final newFile = await file.copy(newPath);

        // Save in DB
        await DBHelper.insertImage(newFile.path);

        // Try to delete original from gallery
        // Delete original from gallery
        try {
          final ps = await PhotoManager.requestPermissionExtend();
          if (!ps.isAuth) {
            debugPrint("Gallery permission not granted");
            return;
          }

          final albums = await PhotoManager.getAssetPathList(
            type: RequestType.image,
            onlyAll: true,
          );

          for (var album in albums) {
            int page = 0;
            bool hasMore = true;

            while (hasMore) {
              final items = await album.getAssetListPaged(page: page, size: 100);
              if (items.isEmpty) {
                hasMore = false;
              } else {
                for (var asset in items) {
                  final f = await asset.file;
                  if (f?.path == picked.path) {
                    await PhotoManager.editor.deleteWithIds([asset.id]);
                    debugPrint("✅ Deleted from gallery: ${f?.path}");
                    hasMore = false;
                    break;
                  }
                }
                page++;
              }
            }
          }
        } catch (e) {
          debugPrint("Delete failed: $e");
        }
      }

      _loadImages();
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  Future<void> _deleteLockedImage(int id, String path) async {
    await DBHelper.deleteImage(id);
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
    _loadImages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image Locker")),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickAndLockImages,
        child: const Icon(Icons.lock),
      ),
      body: _images.isEmpty
          ? const Center(child: Text("No locked images"))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: _images.length,
              itemBuilder: (context, index) {
                final img = _images[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(img['path']), fit: BoxFit.cover),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteLockedImage(img['id'], img['path']),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

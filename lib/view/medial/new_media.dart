import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(MaterialApp(home: FolderLockerApp()));
}

class FolderLockerApp extends StatefulWidget {
  @override
  State<FolderLockerApp> createState() => _FolderLockerAppState();
}

class _FolderLockerAppState extends State<FolderLockerApp> {
  Database? db;
  List<Map<String, dynamic>> folders = [];
  List<Map<String, dynamic>> mediaList = [];
  int? currentFolderId;

  @override
  void initState() {
    super.initState();
    initDb();
  }

  Future<void> initDb() async {
    final dbPath = p.join(await getDatabasesPath(), "locker.db");
    db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE folders(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT
          );
        ''');
        await db.execute('''
          CREATE TABLE media(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            folder_id INTEGER,
            original_path TEXT,
            private_path TEXT,
            is_locked INTEGER
          );
        ''');
      },
    );
    loadFolders();
  }

  Future<void> loadFolders() async {
    final data = await db!.query("folders");
    setState(() => folders = data);
  }

  Future<void> loadMedia(int folderId) async {
    final data = await db!.query("media", where: "folder_id=?", whereArgs: [folderId]);
    setState(() => mediaList = data);
  }

  Future<void> createFolder(String name) async {
    await db!.insert("folders", {"name": name});
    loadFolders();
  }

  Future<Directory> getPrivateFolder() async {
    final appDir = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(appDir.path, "locked_media"));
    if (!await folder.exists()) folder.createSync(recursive: true);
    return folder;
  }

  Future<void> pickAndLockMedia() async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      return;
    }

    if (currentFolderId == null) return;

    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.media, allowMultiple: true);

    if (result == null) return;

    final privateDir = await getPrivateFolder();

    for (var path in result.paths) {
      if (path != null) {
        File original = File(path);
        String privatePath = p.join(privateDir.path, p.basename(path));
        await original.copy(privatePath);
        await original.delete(); // move effect

        await db!.insert("media",
            {"folder_id": currentFolderId, "original_path": path, "private_path": privatePath, "is_locked": 1});
      }
    }
    loadMedia(currentFolderId!);
  }

  Future<void> unlockMedia(Map<String, dynamic> media) async {
    File privateFile = File(media["private_path"]);
    if (!await privateFile.exists()) return;

    String originalPath = media["original_path"];
    Directory originalDir = Directory(p.dirname(originalPath));
    if (!await originalDir.exists()) originalDir.createSync(recursive: true);

    await privateFile.copy(originalPath);
    await privateFile.delete();

    await db!.update("media", {"is_locked": 0}, where: "id=?", whereArgs: [media["id"]]);
    loadMedia(currentFolderId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            currentFolderId == null ? "Folder Locker" : folders.firstWhere((f) => f["id"] == currentFolderId)["name"]),
        leading: currentFolderId != null
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() => currentFolderId = null);
                  mediaList = [];
                },
              )
            : null,
      ),
      body: currentFolderId == null
          ? ListView(
              children: [
                for (var folder in folders)
                  ListTile(
                    title: Text(folder["name"]),
                    onTap: () {
                      setState(() => currentFolderId = folder["id"]);
                      loadMedia(folder["id"]);
                    },
                  ),
              ],
            )
          : Column(
              children: [
                ElevatedButton(
                  onPressed: pickAndLockMedia,
                  child: Text("Pick & Lock Media"),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: mediaList.length,
                    itemBuilder: (context, index) {
                      var media = mediaList[index];
                      return ListTile(
                        title: Text(p.basename(media["private_path"])),
                        subtitle: Text(media["is_locked"] == 1 ? "Locked" : "Unlocked"),
                        trailing: media["is_locked"] == 1
                            ? IconButton(
                                icon: Icon(Icons.lock_open),
                                onPressed: () => unlockMedia(media),
                              )
                            : null,
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: currentFolderId == null
          ? FloatingActionButton(
              onPressed: () {
                final controller = TextEditingController();
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Create Folder"),
                    content: TextField(controller: controller),
                    actions: [
                      TextButton(
                        onPressed: () {
                          createFolder(controller.text);
                          Navigator.pop(context);
                        },
                        child: Text("Save"),
                      )
                    ],
                  ),
                );
              },
              child: Icon(Icons.create_new_folder),
            )
          : null,
    );
  }
}

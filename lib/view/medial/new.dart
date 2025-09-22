import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class LockedMedia {
  final String id;
  final List<String> originalPaths;
  final String storedFolderPath;
  final DateTime lockedAt;

  LockedMedia({
    required this.id,
    required this.originalPaths,
    required this.storedFolderPath,
    required this.lockedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalPaths': originalPaths,
        'storedFolderPath': storedFolderPath,
        'lockedAt': lockedAt.toIso8601String(),
      };

  static LockedMedia fromJson(Map<String, dynamic> j) => LockedMedia(
        id: j['id'],
        originalPaths: List<String>.from(j['originalPaths']),
        storedFolderPath: j['storedFolderPath'],
        lockedAt: DateTime.parse(j['lockedAt']),
      );
}

class MediaLockerController extends GetxController {
  final RxList<LockedMedia> lockedMediaList = <LockedMedia>[].obs;

  late Directory appDocDir;

  final String indexFileName = 'locked_media_index.json';

  @override
  void onInit() {
    super.onInit();
    initPaths();
  }

  Future<void> initPaths() async {
    appDocDir = await getApplicationDocumentsDirectory();
    await loadIndex();
  }

  Future<File> indexFile() async {
    final f = File('${appDocDir.path}/$indexFileName');
    if (!await f.exists()) await f.create();
    return f;
  }

  Future<void> loadIndex() async {
    final f = await indexFile();
    try {
      final text = await f.readAsString();
      if (text.trim().isEmpty) {
        lockedMediaList.value = [];
        return;
      }
      final data = jsonDecode(text) as List<dynamic>;
      lockedMediaList.value = data.map((e) => LockedMedia.fromJson(e)).toList();
    } catch (_) {
      lockedMediaList.value = [];
    }
  }

  Future<void> saveIndex() async {
    final f = await indexFile();
    final data = lockedMediaList.map((e) => e.toJson()).toList();
    await f.writeAsString(jsonEncode(data));
  }

  Future<void> copyDirectory(Directory source, Directory destination, {bool ignoreNomedia = false}) async {
    if (!destination.existsSync()) {
      destination.createSync(recursive: true);
    }

    await for (var entity in source.list(recursive: false)) {
      final name = entity.uri.pathSegments.last;
      // Skip .nomedia file when restoring
      if (ignoreNomedia && name == ".nomedia") continue;
      if (entity is File) {
        File newFile = File("${destination.path}/$name");
        await newFile.writeAsBytes(await entity.readAsBytes());
      } else if (entity is Directory) {
        Directory newSubDir = Directory("${destination.path}/$name");
        await copyDirectory(entity, newSubDir, ignoreNomedia: ignoreNomedia);
      }
    }
  }

  Future<void> pickAndLockMedia() async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.media,
      allowMultiple: true,
    );

    if (result == null) return;

    List<String> selectedPaths = result.paths.whereType<String>().toList();

    // Use default folder
    final destParent = await getDefaultLockedFolder();

    try {
      for (var path in selectedPaths) {
        final file = File(path);
        final newFile = File('${destParent.path}/${file.uri.pathSegments.last}');

        // Copy file into locked folder
        if (!await newFile.exists()) {
          await newFile.writeAsBytes(await file.readAsBytes());
        } else {
          final newName = "${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
          await File('${destParent.path}/$newName').writeAsBytes(await file.readAsBytes());
        }

        // (Optional) delete from gallery so it disappears
        if (await file.exists()) {
          await file.delete();
        }
      }

      Get.snackbar("Success", "Media locked securely!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<Directory> getDefaultLockedFolder() async {
    Directory? externalDir = await getExternalStorageDirectory();
    // Example: /storage/emulated/0/Android/data/com.example.app/files/LockedMedia
    final folder = Directory("${externalDir!.path}/LockedMedia");

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    // Create .nomedia file so files inside don't show in Gallery
    final nomedia = File("${folder.path}/.nomedia");
    if (!await nomedia.exists()) {
      await nomedia.create();
    }

    return folder;
  }

  Future<void> unlockMedia(LockedMedia lockedMedia) async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }

    final srcDir = Directory(lockedMedia.storedFolderPath);
    if (!await srcDir.exists()) {
      Get.snackbar("Error", "Locked folder not found in app storage.");
      return;
    }

    try {
      for (int i = 0; i < lockedMedia.originalPaths.length; i++) {
        final srcFile =
            File('${lockedMedia.storedFolderPath}/${File(lockedMedia.originalPaths[i]).uri.pathSegments.last}');
        if (await srcFile.exists()) {
          await srcFile.copy(lockedMedia.originalPaths[i]);
        }
      }

      await srcDir.delete(recursive: true);
      lockedMediaList.removeWhere((f) => f.id == lockedMedia.id);
      await saveIndex();

      Get.snackbar("Success", "Media restored to gallery!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<List<FileSystemEntity>> openLockedMediaFolder(LockedMedia media) async {
    final dir = Directory(media.storedFolderPath);
    if (!await dir.exists()) {
      Get.snackbar("Error", "Folder not found in app storage!");
      return [];
    }
    return dir.listSync(recursive: false);
  }
}

// --- UI ---
class MediaLocker extends StatelessWidget {
  final MediaLockerController controller = Get.put(MediaLockerController());

  MediaLocker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Media Locker"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: controller.pickAndLockMedia,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.lockedMediaList.isEmpty) {
          return const Center(
            child: Text("No locked media yet. Tap + to lock images/videos."),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          itemCount: controller.lockedMediaList.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, index) {
            final folder = controller.lockedMediaList[index];
            return GestureDetector(
              onTap: () => _openFolder(context, folder),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    Positioned.fill(child: _thumbnail(folder)),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: IconButton(
                        icon: const Icon(Icons.lock_open),
                        onPressed: () => controller.unlockMedia(folder),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _thumbnail(LockedMedia folder) {
    final dir = Directory(folder.storedFolderPath);
    if (!dir.existsSync()) return const Icon(Icons.folder, size: 50);
    final files = dir.listSync().where((f) => f is File && !f.path.endsWith('.nomedia')).toList();
    if (files.isEmpty) return const Icon(Icons.folder, size: 50);
    final firstFile = files.first as File;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(firstFile, fit: BoxFit.cover),
    );
  }

  void _openFolder(BuildContext context, LockedMedia folder) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LockedFolderDetailScreen(folder: folder)),
    );
  }
}

class LockedFolderDetailScreen extends StatefulWidget {
  final LockedMedia folder;

  const LockedFolderDetailScreen({super.key, required this.folder});

  @override
  State<LockedFolderDetailScreen> createState() => _LockedFolderDetailScreenState();
}

class _LockedFolderDetailScreenState extends State<LockedFolderDetailScreen> {
  List<FileSystemEntity> files = [];

  @override
  void initState() {
    super.initState();
    final dir = Directory(widget.folder.storedFolderPath);
    files = dir.existsSync() ? dir.listSync().where((f) => f is File && !f.path.endsWith('.nomedia')).toList() : [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Folder Details")),
      body: files.isEmpty
          ? const Center(child: Text("No media inside this folder."))
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: files.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemBuilder: (context, index) {
                final file = files[index] as File;
                final isVideo = file.path.endsWith(".mp4") || file.path.endsWith(".mov");
                return GestureDetector(
                  onTap: () {
                    if (isVideo) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(file: file),
                        ),
                      );
                    }
                  },
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(file, fit: BoxFit.cover),
                      ),
                      if (isVideo)
                        const Positioned(
                          top: 4,
                          left: 4,
                          child: Icon(Icons.videocam, color: Colors.white),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final File file;
  const VideoPlayerScreen({super.key, required this.file});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying ? _controller.pause() : _controller.play();
          });
        },
        child: Icon(_controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

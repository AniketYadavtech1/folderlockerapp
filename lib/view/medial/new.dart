import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class LockedMedia {
  final String id;
  final String originalPath;
  final String storedPath;
  final DateTime lockedAt;
  final bool isVideo;

  LockedMedia({
    required this.id,
    required this.originalPath,
    required this.storedPath,
    required this.lockedAt,
    required this.isVideo,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'originalPath': originalPath,
        'storedPath': storedPath,
        'lockedAt': lockedAt.toIso8601String(),
        'isVideo': isVideo,
      };

  static LockedMedia fromJson(Map<String, dynamic> j) => LockedMedia(
        id: j['id'],
        originalPath: j['originalPath'],
        storedPath: j['storedPath'],
        lockedAt: DateTime.parse(j['lockedAt']),
        isVideo: j['isVideo'],
      );
}

class MediaLockerController extends GetxController {
  final RxList<LockedMedia> lockedMediaList = <LockedMedia>[].obs;
  late Directory lockFolder;
  final String indexFileName = 'locked_media_index.json';

  @override
  void onInit() {
    super.onInit();
    initFolder();
  }

  Future<void> initFolder() async {
    final dir = await getExternalStorageDirectory();
    lockFolder = Directory("${dir!.path}/LockPhoto");
    if (!await lockFolder.exists()) {
      await lockFolder.create(recursive: true);
    }
    final nomedia = File("${lockFolder.path}/.nomedia");
    if (!await nomedia.exists()) await nomedia.create();
    await loadIndex();
  }

  Future<File> indexFile() async {
    final f = File('${lockFolder.path}/$indexFileName');
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

  // Future<void> pickAndLockMedia() async {
  //   if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
  //     Get.snackbar("Permission Denied", "Please allow storage permission!");
  //     return;
  //   }
  //
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //     allowMultiple: true,
  //   );
  //
  //   if (result == null) return;
  //
  //   List<String> selectedPaths = result.paths.whereType<String>().toList();
  //
  //   for (var path in selectedPaths) {
  //     final file = File(path);
  //     final isVideo = path.endsWith(".mp4") || path.endsWith(".mov");
  //
  //     final newFileName = "${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
  //     final storedFile = File("${lockFolder.path}/$newFileName");
  //
  //     try {
  //       // ✅ Copy + Delete instead of rename
  //       final movedFile = await file.copy(storedFile.path);
  //       if (await file.exists()) {
  //         await file.delete();
  //       }
  //
  //       // ✅ Refresh gallery to remove old entry
  //       await MediaScanner.loadMedia(path: path);
  //
  //       // Save info
  //       final lockedMedia = LockedMedia(
  //         id: DateTime.now().millisecondsSinceEpoch.toString(),
  //         originalPath: path,
  //         storedPath: movedFile.path,
  //         lockedAt: DateTime.now(),
  //         isVideo: isVideo,
  //       );
  //
  //       lockedMediaList.add(lockedMedia);
  //     } catch (e) {
  //       Get.snackbar("Error", e.toString());
  //     }
  //   }
  //
  //   await saveIndex();
  //   Get.snackbar("Success", "${selectedPaths.length} files locked securely!");
  // }

  // Future<void> pickAndLockMedia() async {
  //   if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
  //     Get.snackbar("Permission Denied", "Please allow storage permission!");
  //     return;
  //   }
  //
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.image,
  //     allowMultiple: true,
  //   );
  //
  //   if (result == null) return;
  //
  //   List<String> selectedPaths = result.paths.whereType<String>().toList();
  //
  //   for (var path in selectedPaths) {
  //     final file = File(path);
  //     final isVideo = path.endsWith(".mp4") || path.endsWith(".mov");
  //
  //     final newFileName = "${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
  //     final storedFile = File("${lockFolder.path}/$newFileName");
  //
  //     try {
  //       // Copy file to hidden folder
  //       final movedFile = await file.copy(storedFile.path);
  //
  //       // Delete original file
  //       if (await file.exists()) {
  //         await file.delete();
  //
  //         // ❌ Remove from gallery using photo_manager
  //         final assetPath = await PhotoManager.getAssetPathList(
  //           onlyAll: true,
  //           type: isVideo ? RequestType.video : RequestType.image,
  //         );
  //
  //         for (var pathItem in assetPath) {
  //           final assets = await pathItem.getAssetListRange(start: 0, end: 1000); // get assets
  //           for (var asset in assets) {
  //             final fileData = await asset.file;
  //             if (fileData != null && fileData.path == path) {
  //               await PhotoManager.editor.deleteWithIds([asset.id]);
  //             }
  //           }
  //         }
  //       }
  //
  //       // Save info
  //       final lockedMedia = LockedMedia(
  //         id: DateTime.now().millisecondsSinceEpoch.toString(),
  //         originalPath: path,
  //         storedPath: movedFile.path,
  //         lockedAt: DateTime.now(),
  //         isVideo: isVideo,
  //       );
  //
  //       lockedMediaList.add(lockedMedia);
  //     } catch (e) {
  //       Get.snackbar("Error", e.toString());
  //     }
  //   }
  //
  //   await saveIndex();
  //   Get.snackbar("Success", "${selectedPaths.length} files locked securely!");
  // }

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

    for (var path in selectedPaths) {
      final file = File(path);
      final isVideo = path.endsWith(".mp4") || path.endsWith(".mov");

      final newFileName = "${DateTime.now().millisecondsSinceEpoch}_${file.uri.pathSegments.last}";
      final storedFile = File("${lockFolder.path}/$newFileName");

      try {
        // ✅ Copy file to hidden folder (with .nomedia)
        final movedFile = await file.copy(storedFile.path);

        // ✅ Delete original file from gallery folder
        if (await file.exists()) {
          await file.delete();
        }
        await refreshGallery(newFileName);

        // ❌ Ab gallery me manually remove mat karo
        // .nomedia folder me hone se ye automatically gallery me nahi dikhega

        // Save info
        final lockedMedia = LockedMedia(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          originalPath: path,
          storedPath: movedFile.path,
          lockedAt: DateTime.now(),
          isVideo: isVideo,
        );

        lockedMediaList.add(lockedMedia);
      } catch (e) {
        Get.snackbar("Error", e.toString());
      }
    }

    await saveIndex();
    Get.snackbar("Success", "${selectedPaths.length} files locked securely!");
  }

  Future<void> refreshGallery(String path) async {
    try {
      final assetPathList = await PhotoManager.getAssetPathList(
        onlyAll: true,
        type: RequestType.image,
      );

      for (var album in assetPathList) {
        final assets = await album.getAssetListRange(start: 0, end: 1000);
        for (var asset in assets) {
          final file = await asset.file;
          if (file != null && file.path == path) {
            await PhotoManager.editor.deleteWithIds([asset.id]);
          }
        }
      }
    } catch (e) {
      print("Gallery refresh error: $e");
    }
  }

  Future<void> unlockMedia(LockedMedia media) async {
    if (await Permission.storage.request().isDenied && await Permission.manageExternalStorage.request().isDenied) {
      Get.snackbar("Permission Denied", "Please allow storage permission!");
      return;
    }

    try {
      final storedFile = File(media.storedPath);
      if (await storedFile.exists()) {
        final originalFile = File(media.originalPath);
        await storedFile.copy(originalFile.path);
        await storedFile.delete();
      }

      lockedMediaList.removeWhere((f) => f.id == media.id);
      await saveIndex();
      Get.snackbar("Success", "Media restored to original location!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  Future<void> deleteMedia(LockedMedia media) async {
    try {
      final storedFile = File(media.storedPath);
      if (await storedFile.exists()) await storedFile.delete();
      lockedMediaList.removeWhere((f) => f.id == media.id);
      await saveIndex();
      Get.snackbar("Deleted", "Media deleted permanently!");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
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
              crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemBuilder: (context, index) {
            final media = controller.lockedMediaList[index];
            return GestureDetector(
              onTap: () => _openMedia(context, media),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(File(media.storedPath), fit: BoxFit.cover),
                  ),
                  if (media.isVideo)
                    const Positioned(top: 4, left: 4, child: Icon(Icons.videocam, color: Colors.white)),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.lock_open),
                          onPressed: () => controller.unlockMedia(media),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => controller.deleteMedia(media),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _openMedia(BuildContext context, LockedMedia media) {
    if (media.isVideo) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VideoPlayerScreen(file: File(media.storedPath))),
      );
    }
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
            ? AspectRatio(aspectRatio: _controller.value.aspectRatio, child: VideoPlayer(_controller))
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

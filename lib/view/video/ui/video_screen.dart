import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/video/controller/video_con.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VideoMediaController con = Get.put(VideoMediaController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Locked Videos"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => con.pickAndLockFromGallery(context),
          ),
          IconButton(
            icon: Obx(() => Icon(
                  con.isGridView.value ? Icons.list : Icons.grid_view,
                )),
            onPressed: con.toggleView,
          ),
        ],
      ),
      body: Obx(() {
        if (con.load.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (con.lockedVideos.isEmpty) {
          return const Center(child: Text("No locked videos found."));
        }

        return con.isGridView.value ? _buildGridView(con) : _buildListView(con);
      }),
    );
  }

  Widget _buildGridView(VideoMediaController con) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: con.lockedVideos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final file = con.lockedVideos[index];
        return _VideoTile(file: file, con: con);
      },
    );
  }

  Widget _buildListView(VideoMediaController con) {
    return ListView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: con.lockedVideos.length,
      itemBuilder: (context, index) {
        final file = con.lockedVideos[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _VideoTile(file: file, con: con),
        );
      },
    );
  }
}

class _VideoTile extends StatefulWidget {
  final File file;
  final VideoMediaController con;

  const _VideoTile({required this.file, required this.con});

  @override
  State<_VideoTile> createState() => _VideoTileState();
}

class _VideoTileState extends State<_VideoTile> {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
        setState(() {});
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _videoController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  )
                : Container(
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.lock_open, color: Colors.white),
                  onPressed: () => widget.con.unlockVideo(widget.file), // Unlock video
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.con.deleteLockedVideo(widget.file), // Delete
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

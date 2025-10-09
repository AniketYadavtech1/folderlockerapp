import 'dart:io';

import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/pic_con.dart';
import 'package:get/get.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<File> allImages;
  final int initialIndex;

  const ImagePreviewScreen({
    super.key,
    required this.allImages,
    required this.initialIndex,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late PageController _pageController;
  late int _currentIndex;
  final con = Get.find<MediaController>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  Future<void> _deleteImage() async {
    if (widget.allImages.isEmpty) return;
    final image = widget.allImages[_currentIndex];
    await con.deleteLockedImage(image);

    setState(() {
      widget.allImages.removeAt(_currentIndex);
      if (_currentIndex >= widget.allImages.length && widget.allImages.isNotEmpty) {
        _currentIndex = widget.allImages.length - 1;
      }
    });

    if (widget.allImages.isEmpty) Get.back();
  }

  Future<void> _unlockImage() async {
    if (widget.allImages.isEmpty) return;
    final image = widget.allImages[_currentIndex];
    await con.unlockImage(image);

    setState(() {
      widget.allImages.removeAt(_currentIndex);
      if (_currentIndex >= widget.allImages.length && widget.allImages.isNotEmpty) {
        _currentIndex = widget.allImages.length - 1;
      }
    });

    if (widget.allImages.isEmpty) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white10,
        title: Text(
          "Image ${_currentIndex + 1} / ${widget.allImages.length}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open, color: Colors.greenAccent),
            onPressed: _unlockImage,
            tooltip: "Unlock",
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: _deleteImage,
            tooltip: "Delete",
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.allImages.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          final image = widget.allImages[index];
          return Center(
            child: Hero(
              tag: image.path,
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 4.0,
                clipBehavior: Clip.none,
                child: Image.file(
                  image,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class FileViewScreen extends StatelessWidget {
  final FileSystemEntity file;
  const FileViewScreen({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    final name = file.path.split('/').last;

    if (file is! File) {
      return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: const Center(child: Text("Not a file!")),
      );
    }

    final extension = name.split('.').last.toLowerCase();

    Widget content;
    if (["png", "jpg", "jpeg", "gif"].contains(extension)) {
      //  Image Preview
      content = Image.file(File(file.path), fit: BoxFit.contain);
    } else if (["txt", "log", "json", "md"].contains(extension)) {
      //  Text Preview
      final text = File(file.path).readAsStringSync();
      content = SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Text(text),
      );
    } else if (extension == "pdf") {
      // ✅ PDF Preview using flutter_pdfview
      content = PDFView(
        filePath: file.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      );
    } else {
      // ✅ Generic Fallback
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_drive_file, size: 60),
            const SizedBox(height: 12),
            Text(
              "Can't preview this file.\n\nPath: ${file.path}",
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: content),
    );
  }
}

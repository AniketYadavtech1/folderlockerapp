import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/new_mediacon.dart';
import 'package:folderlockerapp/view/media/ui/media_screen.dart';
import 'package:folderlockerapp/view/media/ui/new_media.dart';
import 'package:folderlockerapp/view/themes/utill/app_button.dart';
import 'package:folderlockerapp/view/video/ui/video_screen.dart';
import 'package:get/get.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final con = Get.put(NewMediaController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("welcome"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            AppButton(
                text: "New MediaScreenView",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NewMediaScreenView()));
                }),
            SizedBox(height: 20),
            AppButton(
                text: "MediaScreenView",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MediaScreenView()));
                }),
            SizedBox(height: 20),
            AppButton(
                text: "Video",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => VideoScreen()));
                }),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

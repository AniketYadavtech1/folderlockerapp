import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/fmedia/ui/media.dart';
import 'package:folderlockerapp/view/media/hidden_img2.dart';
import 'package:folderlockerapp/view/media/ui/new_media_screen.dart';
import 'package:folderlockerapp/view/media/ui/new_one.dart';
import 'package:folderlockerapp/view/themes/utill/app_button.dart';
import 'package:get/get.dart';

import '../media/controller/pic_con.dart';
import '../media/hidden_img1.dart';
import '../media/incrept_decreption.dart';
import '../media/ui/media_screen.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final con = Get.put(MediaController());

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
                text: "imageHide 1",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HiddenImageView1()));
                }),
            SizedBox(height: 20),
            AppButton(
                text: "imageHide 2",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HiddenImageView2()));
                }),
            AppButton(
                text: "Increption",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => IncreptionDecreption()));
                }),
            SizedBox(height: 20),
            AppButton(
                text: "MediaScreen",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MediaScreenView()));
                }),
            AppButton(
                text: "Folder Screen",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => FolderListScreen()));
                }),
            SizedBox(width: 10),
            AppButton(
                text: "Gallery Delition",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GalleryDeleteScreen()));
                }),
            AppButton(
                text: "Gallery Delition",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => MediaScreenViewone()));
                }),
          ],
        ),
      ),
    );
  }
}

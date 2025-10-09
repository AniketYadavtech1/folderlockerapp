import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/controller/pic_con.dart';
import 'package:folderlockerapp/view/media/ui/new_media.dart';
import 'package:folderlockerapp/view/themes/utill/app_button.dart';
import 'package:get/get.dart';

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
                text: "Gallery Delition",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => NewMediaScreenView()));
                }),
            SizedBox(height: 20),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}

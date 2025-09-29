import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/media/hidden_img2.dart';
import 'package:folderlockerapp/view/themes/utill/app_button.dart';

import '../media/hidden_img1.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HiddenImage1View()));
                }),
            SizedBox(height: 20),
            AppButton(
                text: "imageHide 2",
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HiddenImageView2()));
                }),
          ],
        ),
      ),
    );
  }
}

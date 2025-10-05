import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/folder/controller/controller.dart';
import 'package:folderlockerapp/view/home/home_view.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkPermission();
  }

  final con = Get.put(FolderLockers());

  Future<void> checkPermission() async {
    await Future.delayed(const Duration(seconds: 2));
    // if (await Permission.storage.isDenied || await Permission.manageExternalStorage.isDenied) {
    //   await Permission.manageExternalStorage.request();
    // }
    bool granted = (await Permission.storage.isDenied || await Permission.manageExternalStorage.isDenied);
    if (granted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeView()),
      );
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text("Folder Locker App", style: TextStyle(fontSize: 22)),
      ),
    );
  }
}

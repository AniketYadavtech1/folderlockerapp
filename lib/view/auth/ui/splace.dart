import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/folder/controller/controller.dart';
import 'package:folderlockerapp/view/folder/ui/folder_locker.dart';
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
    _checkPermission();
  }

  final con = Get.put(FolderLockerController());

  Future<void> _checkPermission() async {
    await Future.delayed(const Duration(seconds: 2)); // splash delay
    bool granted = await openAppSettings();

    if (granted) {
      //  Permission granted → Go to FolderLocker Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LockedFoldersScreen()),
      );
    } else {
      // Permission denied → Open Settings

      // Exit app or retry after settings
    }
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

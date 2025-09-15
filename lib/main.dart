import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/folder/ui/folder_locker.dart';
import 'package:folderlockerapp/view/pin/controller/pin_controller.dart';
import 'package:folderlockerapp/view/themes/controller/theme_controller.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PinController pinController = Get.put(PinController());
    final ThemeController themeController = Get.put(ThemeController());

    // return GetMaterialApp(
    //   debugShowCheckedModeBanner: false,
    //   title: 'Folder Locker App',
    //   theme: ThemeData(primarySwatch: Colors.blue),
    //   home: LockedFoldersScreen(),
    //
    //   // Obx(() {
    //   //   if (pinController.isPinCreated.value) {
    //   //     return VerifyPinScreen();
    //   //   } else {
    //   //     return CreatePinScreen();
    //   //   }
    //   // }),
    // );
    return Obx(() {
      return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Folder Locker App',
        theme: themeController.themeData,
        home: LockedFoldersScreen(),
      );
    });
  }
}

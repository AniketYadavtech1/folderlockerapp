import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:folderlockerapp/view/folder/ui/new_folder_locker.dart';
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

    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(() => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Folder Locker App',
            theme: themeController.themeData,
            // home: LockedFoldersScreen(),
            // home: NewLockedFoldersScreen(),
            // home: MediaLockerScreen(),
            // home: LockerDemoScreen(),
            home: NewLockedFoldersScreen()));
      },
    );
  }
}

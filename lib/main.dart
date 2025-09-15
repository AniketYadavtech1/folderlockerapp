import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/pin/controller/pin_controller.dart';
import 'package:folderlockerapp/view/pin/ui/verify_pin.dart';
import 'package:get/get.dart';

import 'view/pin/ui/create_pin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final PinController pinController = Get.put(PinController());

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Folder Locker App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Obx(() {
        if (pinController.isPinCreated.value) {
          return VerifyPinScreen();
        } else {
          return CreatePinScreen();
        }
      }),
    );
  }
}

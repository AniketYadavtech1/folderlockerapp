import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/folder/ui/folder_locker.dart';
import 'package:folderlockerapp/view/pin/controller/pin_controller.dart';
import 'package:get/get.dart';

class VerifyPinScreen extends StatelessWidget {
  final PinController controller = Get.find();

  final TextEditingController pinController = TextEditingController();

  VerifyPinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Enter PIN'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                bool ok = await controller.verifyPin(pinController.text);
                if (ok) {
                  Get.off(() => LockedFoldersScreen());
                } else {
                  Get.snackbar('Error', 'Wrong PIN');
                }
              },
              child: const Text('Unlock'),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

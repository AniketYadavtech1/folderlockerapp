import 'package:flutter/material.dart';
import 'package:folderlockerapp/view/pin/ui/verify_pin.dart';
import 'package:get/get.dart';

import '../controller/pin_controller.dart';

class CreatePinScreen extends StatelessWidget {
  final PinController controller = Get.put(PinController());
  final TextEditingController pinController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  CreatePinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create PIN')),
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
            TextField(
              controller: confirmController,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Confirm PIN'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                if (pinController.text == confirmController.text && pinController.text.isNotEmpty) {
                  await controller.createPin(pinController.text);
                  Get.off(() => VerifyPinScreen());
                } else {
                  Get.snackbar('Error', 'PINs do not match!');
                }
              },
              child: const Text('Save PIN'),
            ),
          ],
        ),
      ),
    );
  }
}

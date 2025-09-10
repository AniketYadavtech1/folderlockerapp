import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PinCheckScreen extends StatefulWidget {
  const PinCheckScreen({super.key});

  @override
  State<PinCheckScreen> createState() => _PinCheckScreenState();
}

class _PinCheckScreenState extends State<PinCheckScreen> {
  String? savedPin;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  Future<void> _loadPin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      savedPin = prefs.getString('user_pin');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (savedPin == null) {
      return const CreatePinScreen();
    } else {
      return EnterPinScreen(correctPin: savedPin!);
    }
  }
}

// Screen to create PIN
class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  final TextEditingController pinController = TextEditingController();

  Future<void> _savePin() async {
    if (pinController.text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_pin', pinController.text);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => EnterPinScreen(correctPin: pinController.text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create PIN")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Set your PIN", style: TextStyle(fontSize: 20)),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter PIN"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePin,
              child: const Text("Save PIN"),
            ),
          ],
        ),
      ),
    );
  }
}

// Screen to enter PIN
class EnterPinScreen extends StatefulWidget {
  final String correctPin;
  const EnterPinScreen({super.key, required this.correctPin});

  @override
  State<EnterPinScreen> createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  final TextEditingController pinController = TextEditingController();
  String? errorMessage;

  void _checkPin() {
    if (pinController.text == widget.correctPin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        errorMessage = "Incorrect PIN!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter PIN")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Enter your PIN", style: TextStyle(fontSize: 20)),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Enter PIN"),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 10),
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkPin,
              child: const Text("Unlock"),
            ),
          ],
        ),
      ),
    );
  }
}

// Home screen after unlock
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(
        child: Text("Unlocked! 🎉", style: TextStyle(fontSize: 24)),
      ),
    );
  }
}

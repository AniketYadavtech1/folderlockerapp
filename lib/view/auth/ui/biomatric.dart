import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthScreen extends StatefulWidget {
  const BiometricAuthScreen({super.key});

  @override
  State<BiometricAuthScreen> createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  String _authMessage = "Not Authenticated";

  ///  Authenticate strictly with fingerprint
  Future<void> _authenticate() async {
    try {
      //  Check if device supports biometrics
      bool isSupported = await auth.isDeviceSupported();
      bool canCheck = await auth.canCheckBiometrics;

      if (!isSupported || !canCheck) {
        setState(() {
          _authMessage = "Biometric authentication not supported on this device!";
        });
        return;
      }

      //  Get available biometrics
      List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();

      if (!availableBiometrics.contains(BiometricType.fingerprint)) {
        setState(() {
          _authMessage = "No fingerprint enrolled!";
        });
        return;
      }

      // Authenticate using fingerprint only
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Scan your fingerprint to access Home Page',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } else {
        setState(() {
          _authMessage = "Authentication Failed";
        });
      }
    } catch (e) {
      setState(() {
        _authMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Authentication")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_authMessage, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _authenticate,
                child: const Text("Login with Fingerprint"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home Page")),
      body: const Center(
        child: Text(
          "🎉 Welcome! Fingerprint verified successfully.",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

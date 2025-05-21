import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/welcome');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(106, 133, 41, 208),
      body: Center(
        child: Image.asset(
          'assets/logo1.png',
          width: MediaQuery.of(context).size.width, // full width
          fit: BoxFit.contain, // maintains aspect ratio without distortion
        ),
      ),
    );
  }
}
import 'dart:async';

import 'package:flutter/material.dart';

import 'signin_screen.dart';
import 'firebase_error_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'renter_home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  final bool firebaseReady;

  const WelcomeScreen({super.key, required this.firebaseReady});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  Timer? _navTimer;

  @override
  void initState() {
    super.initState();
    // Short delay so the user sees the welcome screen briefly before navigating on.
    _navTimer = Timer(const Duration(milliseconds: 1600), _goNext);
  }

  void _goNext() {
    if (!mounted) return;
    _navTimer?.cancel();
    _navTimer = null;
    if (widget.firebaseReady) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RenterHomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInScreen()),
        );
      }
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const FirebaseConfigErrorScreen()),
      );
    }
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _goNext,
        child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              // App name
              const Text(
                'wayfare',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // App logo
              Image.asset(
                'assets/images/wayfarelogo.jpg',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),

              const SizedBox(height: 36),

              // Quote with italic font and some spacing from the logo
              const Text(
                'Travling easy',
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}

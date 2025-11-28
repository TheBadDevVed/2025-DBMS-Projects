import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'services/car_provider.dart';
import 'screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseReady = false;
  try {
    // If firebase_options.dart is configured, prefer using it.
    // On web, Firebase requires explicit options; without them, initialization will throw.
    await Firebase.initializeApp();
    firebaseReady = true;
  } catch (e, s) {
    // Avoid crashing to a blank page; surface a helpful screen instead.
    debugPrint('Firebase initialization failed: $e');
    debugPrint('$s');
  }
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CarProvider())],
      child: MyApp(firebaseReady: firebaseReady),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool firebaseReady;

  const MyApp({super.key, required this.firebaseReady});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Rental App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WelcomeScreen(firebaseReady: firebaseReady),
    );
  }
}

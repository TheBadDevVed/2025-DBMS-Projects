import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';
import 'renter_home_screen.dart';
import '../../widgets/custom_textfield.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();

  bool isLoading = false;
  bool showPassword = false;

  void signIn() async {
    setState(() => isLoading = true);
    try {
      await auth.signInWithEmail(
          emailController.text.trim(), passwordController.text.trim());
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RenterHomeScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void googleSignIn() async {
    try {
      await auth.signInWithGoogle();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Google Sign-In failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _CarWithHeadlights(isOn: showPassword),
                const SizedBox(height: 20),
                Text(
                  "Welcome Back!",
                  style: GoogleFonts.poppins(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "Login to rent your favorite car",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                    hintText: "Email", controller: emailController),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Password",
                  controller: passwordController,
                  obscureText: !showPassword,
                  suffixIcon: IconButton(
                    icon: Icon(showPassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => showPassword = !showPassword),
                  ),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : signIn,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Sign In",
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  icon: Icon(Icons.login, color: Colors.red),
                  label: const Text(
                    "Continue with Google",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: googleSignIn,
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SignUpScreen())),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CarWithHeadlights extends StatelessWidget {
  final bool isOn;
  const _CarWithHeadlights({required this.isOn});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.directions_car, size: 120, color: Colors.blue.shade700),
          Positioned(
            left: 28,
            bottom: 28,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 12,
              height: 8,
              decoration: BoxDecoration(
                color: isOn ? Colors.yellow.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(3),
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.85),
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.5),
                          blurRadius: 36,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
          ),
          Positioned(
            right: 28,
            bottom: 28,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 12,
              height: 8,
              decoration: BoxDecoration(
                color: isOn ? Colors.yellow.shade600 : Colors.white,
                borderRadius: BorderRadius.circular(3),
                boxShadow: isOn
                    ? [
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.85),
                          blurRadius: 20,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: Colors.yellow.withOpacity(0.5),
                          blurRadius: 36,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

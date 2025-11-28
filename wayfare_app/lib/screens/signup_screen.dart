import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import 'signin_screen.dart';
import 'renter_home_screen.dart';
import '../../widgets/custom_textfield.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final firstNameController = TextEditingController();
  final middleNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final mobileController = TextEditingController();
  final driverLicenseController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final auth = AuthService();
  bool isLoading = false;
  bool showPassword = false;

  void signUp() async {
    // Validate mobile number (strictly 10 digits)
    if (mobileController.text.trim().length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mobile number must be exactly 10 digits')),
      );
      return;
    }

    // Validate all required fields
    if (firstNameController.text.trim().isEmpty ||
        lastNameController.text.trim().isEmpty ||
        driverLicenseController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      // Default to 'renter' for all new signups
      final userCred = await auth.signUpWithEmail(
        emailController.text.trim(),
        passwordController.text.trim(),
        'renter',
        firstName: firstNameController.text.trim(),
        middleName: middleNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        mobile: mobileController.text.trim(),
        driverLicense: driverLicenseController.text.trim(),
      );

      if (!mounted) return;

      // Always navigate to RenterHomeScreen
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const RenterHomeScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
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
                  "Create Account",
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Sign up to start using the app",
                  style: GoogleFonts.poppins(color: Colors.grey[600]),
                ),
                const SizedBox(height: 30),
                CustomTextField(
                  hintText: "First Name *",
                  controller: firstNameController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Middle Name (Optional)",
                  controller: middleNameController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Last Name *",
                  controller: lastNameController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Mobile Number * (10 digits)",
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Driver License Number *",
                  controller: driverLicenseController,
                ),
                const SizedBox(height: 15),
                CustomTextField(
                  hintText: "Email",
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : signUp,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Sign Up",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SignInScreen()),
                  ),
                  child: const Text("Already have an account? Login"),
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
          // Left headlight
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
          // Right headlight
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

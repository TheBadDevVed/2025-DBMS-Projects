import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final String? uid = auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: uid == null
          ? const Center(child: Text("No user logged in"))
          : StreamBuilder<DocumentSnapshot>(
              stream: firestore.collection('users').doc(uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text('Error loading profile: ${snapshot.error}'),
                      ],
                    ),
                  );
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text('User data not found'),
                        const SizedBox(height: 8),
                        Text(
                          'UID: $uid',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                var userData = snapshot.data!.data() as Map<String, dynamic>;

                // Debug: Print user data
                debugPrint('Profile Data: $userData');

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Header with Gradient
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade700,
                              Colors.blue.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    userData['avatarIcon'] != null
                                        ? IconData(
                                            userData['avatarIcon'],
                                            fontFamily: 'MaterialIcons',
                                          )
                                        : Icons.person,
                                    size: 50,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                                Positioned(
                                  right: -8,
                                  bottom: -8,
                                  child: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade700,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 3,
                                          offset: const Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      icon: const Icon(
                                        Icons.edit_rounded,
                                        size: 20,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: const Text('Choose Avatar'),
                                            content: Wrap(
                                              spacing: 10,
                                              runSpacing: 10,
                                              children:
                                                  [
                                                        Icons.person,
                                                        Icons.face,
                                                        Icons.face_2,
                                                        Icons.face_3,
                                                        Icons.face_4,
                                                        Icons.face_5,
                                                        Icons.face_6,
                                                        Icons.emoji_emotions,
                                                        Icons.emoji_people,
                                                        Icons.sports,
                                                        Icons.catching_pokemon,
                                                        Icons.child_care,
                                                      ]
                                                      .map(
                                                        (icon) => InkWell(
                                                          onTap: () async {
                                                            try {
                                                              await firestore
                                                                  .collection(
                                                                    'users',
                                                                  )
                                                                  .doc(uid)
                                                                  .update({
                                                                    'avatarIcon':
                                                                        icon.codePoint,
                                                                  });
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                      'Avatar updated successfully',
                                                                    ),
                                                                    duration:
                                                                        Duration(
                                                                          seconds:
                                                                              1,
                                                                        ),
                                                                  ),
                                                                );
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              }
                                                            } catch (e) {
                                                              if (mounted) {
                                                                ScaffoldMessenger.of(
                                                                  context,
                                                                ).showSnackBar(
                                                                  SnackBar(
                                                                    content: Text(
                                                                      'Failed to update avatar: $e',
                                                                    ),
                                                                    backgroundColor:
                                                                        Colors
                                                                            .red,
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            padding:
                                                                const EdgeInsets.all(
                                                                  12,
                                                                ),
                                                            decoration: BoxDecoration(
                                                              color:
                                                                  userData['avatarIcon'] ==
                                                                      icon.codePoint
                                                                  ? Colors
                                                                        .blue
                                                                        .shade50
                                                                  : null,
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                    8,
                                                                  ),
                                                              border:
                                                                  userData['avatarIcon'] ==
                                                                      icon.codePoint
                                                                  ? Border.all(
                                                                      color: Colors
                                                                          .blue
                                                                          .shade700,
                                                                      width: 2,
                                                                    )
                                                                  : null,
                                                            ),
                                                            child: Icon(
                                                              icon,
                                                              size: 40,
                                                              color: Colors
                                                                  .blue
                                                                  .shade700,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: const Text('Cancel'),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Text(
                              userData['name'] ?? 'Name not set',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Unique User ID Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.fingerprint,
                              color: Colors.blue.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Unique User ID',
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userData['uid'] ?? 'N/A',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Personal Information Section
                      Text(
                        'Personal Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildInfoCard(
                        icon: Icons.person_outline,
                        label: 'Full Name',
                        value: userData['name'] ?? 'N/A',
                      ),

                      const SizedBox(height: 25),

                      // Contact Information Section
                      Text(
                        'Contact Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildInfoCard(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: userData['email'] ?? 'N/A',
                      ),
                      _buildInfoCard(
                        icon: Icons.phone_outlined,
                        label: 'Mobile Number',
                        value: userData['phone'] ?? 'N/A',
                      ),

                      const SizedBox(height: 25),

                      // License Information Section
                      Text(
                        'License Information',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 15),

                      _buildInfoCard(
                        icon: Icons.badge_outlined,
                        label: 'Driver License',
                        value: userData['driver_license'] ?? 'N/A',
                      ),

                      const SizedBox(height: 30),

                      // Sign Out Button
                      ElevatedButton.icon(
                        onPressed: () async {
                          await auth.signOut();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/auth_choice', // Route for sign-in/sign-up choice screen
                              (route) => false, // Remove all previous routes
                            );
                          }
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text('Sign Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.blue.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

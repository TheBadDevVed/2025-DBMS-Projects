import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseAuth get auth => _auth;

  Future<UserCredential> signUpWithEmail(
    String email,
    String password,
    String userType, {
    String? firstName,
    String? middleName,
    String? lastName,
    String? mobile,
    String? driverLicense,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // Construct name from firstName, middleName, and lastName
    String fullName = firstName ?? '';
    if (middleName != null && middleName.isNotEmpty) {
      fullName += ' $middleName';
    }
    if (lastName != null && lastName.isNotEmpty) {
      fullName += ' $lastName';
    }
    fullName = fullName.trim();

    await _firestore.collection('users').doc(userCred.user!.uid).set({
      'email': email,
      'uid': userCred.user!.uid,
      'userType': userType,
      'name': fullName.isNotEmpty ? fullName : null,
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phone': mobile,
      'driver_license': driverLicense,
    });

    return userCred;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    final userCred =
        await _auth.signInWithEmailAndPassword(email: email, password: password);
    
    // Ensure user data exists in Firestore (in case user was created before we added this logic)
    final doc = await _firestore.collection('users').doc(userCred.user!.uid).get();
    if (!doc.exists) {
      // Create a basic user document if it doesn't exist
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'email': email,
        'uid': userCred.user!.uid,
        'userType': 'renter',
        'name': null,
        'firstName': null,
        'middleName': null,
        'lastName': null,
        'phone': null,
        'driver_license': null,
      });
    }
    
    return userCred;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update user profile with additional information
  Future<void> updateUserProfile({
    required String uid,
    String? firstName,
    String? middleName,
    String? lastName,
    String? mobile,
    String? driverLicense,
  }) async {
    // Construct name from firstName, middleName, and lastName
    String fullName = firstName ?? '';
    if (middleName != null && middleName.isNotEmpty) {
      fullName += ' $middleName';
    }
    if (lastName != null && lastName.isNotEmpty) {
      fullName += ' $lastName';
    }
    fullName = fullName.trim();

    await _firestore.collection('users').doc(uid).update({
      if (firstName != null) 'firstName': firstName,
      if (middleName != null) 'middleName': middleName,
      if (lastName != null) 'lastName': lastName,
      if (mobile != null) 'phone': mobile,
      if (driverLicense != null) 'driver_license': driverLicense,
      'name': fullName.isNotEmpty ? fullName : null,
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return null;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCred = await _auth.signInWithCredential(credential);

    // Check if user exists in Firestore, else create
    final doc =
        await _firestore.collection('users').doc(userCred.user!.uid).get();
    if (!doc.exists) {
      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'email': userCred.user!.email,
        'uid': userCred.user!.uid,
        'userType': 'renter', // default for Google sign-in
      });
    }

    return userCred;
  }
}

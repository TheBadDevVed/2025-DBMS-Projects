// File: app/reset-password.tsx

import { useLocalSearchParams, useRouter } from 'expo-router';
import React, { useState } from 'react';
import {
  ActivityIndicator,
  Alert,
  Dimensions,
  Image,
  ImageBackground,
  StatusBar,
  StyleSheet,
  Text,
  TextInput,
  TouchableOpacity,
  View,
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';

const { width, height } = Dimensions.get('window');

// This is the background image, you should place your own image here
const backgroundImage = require('../../assets/image_bfba9e.jpg');

export default function ResetPasswordScreen() {
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();
  // Assuming studentId is passed as a route parameter
  const { studentId } = useLocalSearchParams();

  const handleResetPassword = async () => {
    if (!oldPassword || !newPassword || !confirmPassword) {
      Alert.alert('Error', 'Please fill in all fields.');
      return;
    }
    if (newPassword !== confirmPassword) {
      Alert.alert('Error', 'New passwords do not match.');
      return;
    }
    if (newPassword.length < 6) {
      Alert.alert('Error', 'Password must be at least 6 characters long.');
      return;
    }

    setLoading(true);
    try {
      // 1. Get the auth token from storage
      const token = await AsyncStorage.getItem('studentToken');
      const studentId=await AsyncStorage.getItem("studentID");
      // 2. Construct the correct URL with studentId as a parameter
      const apiUrl = `https://gec-mis-backend.onrender.com/api/details/resetpassword/${studentId}`;

      // 3. Make the fetch call
      const response = await fetch(
        apiUrl,
        {
          method: 'PUT',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${token}`, // Add the token here
          },
          // The body should only contain what the backend expects in req.body
          body: JSON.stringify({
            oldPassword,
            newPassword,
            confirmPassword,
          }),
        }
      );

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data.message || 'Something went wrong');
      }

      Alert.alert('Success', 'Password changed successfully!', [
        { text: 'OK', onPress: () => router.back() },
      ]);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'Failed to reset password.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" translucent backgroundColor="transparent" />

      {/* Background Image Section */}
      <ImageBackground source={backgroundImage} style={styles.backgroundImage}>
        <View style={styles.header}>
          <TouchableOpacity onPress={() => router.back()} style={styles.backButton}>
            {/* You can add a back arrow icon here if you'd like */}
          </TouchableOpacity>
        </View>
      </ImageBackground>

      {/* Main Content Card */}
      <View style={styles.contentCard}>
        {/* Profile Image */}

        {/* Profile Name and Form Wrapper */}
        <View style={styles.profileAndFormWrapper}>

          {/* Password Reset Form */}
          <View style={styles.formSection}>
            <Text style={styles.inputLabel}>Old Password:</Text>
            <TextInput
              style={styles.input}
              secureTextEntry
              value={oldPassword}
              onChangeText={setOldPassword}
              placeholder="Enter old password"
              placeholderTextColor="#888"
            />
            <Text style={styles.inputLabel}>New Password:</Text>
            <TextInput
              style={styles.input}
              secureTextEntry
              value={newPassword}
              onChangeText={setNewPassword}
              placeholder="Enter new password"
              placeholderTextColor="#888"
            />

            <Text style={styles.inputLabel}>Confirm Password:</Text>
            <TextInput
              style={styles.input}
              secureTextEntry
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              placeholder="Re-enter new password"
              placeholderTextColor="#888"
            />
          </View>
        </View>
        
        {/* Reset Button */}
        <TouchableOpacity style={styles.resetButton} onPress={handleResetPassword} disabled={loading}>
          {loading ? (
            <ActivityIndicator color="#FFFFFF" />
          ) : (
            <Text style={styles.resetButtonText}>Reset Password</Text>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#F0F4F8',
  },
  backgroundImage: {
    width: '100%',
    height: height * 0.35,
    justifyContent: 'flex-start',
    alignItems: 'flex-start',
    resizeMode: 'cover',
  },
  header: {
    width: '100%',
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
    marginTop: StatusBar.currentHeight,
  },
  backButton: {
    // Style for the back button, if you add one
  },
  contentCard: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    borderTopLeftRadius: 25,
    borderTopRightRadius: 25,
    marginTop: -80, // Moved up to create more overlap
    paddingHorizontal: 35,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: -2 },
    shadowOpacity: 0.1,
    shadowRadius: 5,
    elevation: 8,
  },
  profileImage: {
    width: 90,
    height: 90,
    borderRadius: 45,
    borderWidth: 3,
    borderColor: '#FFFFFF',
    position: 'absolute',
    top: -45, 
    right: 35,
  },
  profileAndFormWrapper: {
    marginTop: 35, // Push content down to start below the profile pic
  },
  profileName: {
    fontSize: 22,
    fontWeight: 'bold',
    color: '#34495E',
    marginBottom: 40,
  },
  formSection: {
    marginBottom: 30,
  },
  inputLabel: {
    fontSize: 16,
    color: '#34495E',
    marginBottom: 8,
    fontWeight: '500',
  },
  input: {
    borderWidth: 1,
    borderColor: '#E0E0E0',
    borderRadius: 8,
    paddingHorizontal: 15,
    paddingVertical: 12,
    fontSize: 16,
    color: '#333',
    marginBottom: 20,
  },
  resetButton: {
    backgroundColor: '#5D9BCC',
    borderRadius: 12,
    paddingVertical: 15,
    alignItems: 'center',
    justifyContent: 'center',
  },
  resetButtonText: {
    fontSize: 18,
    color: '#FFFFFF',
    fontWeight: 'bold',
  },
});
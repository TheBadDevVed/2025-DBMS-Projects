import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, ActivityIndicator, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import axios, { AxiosError } from 'axios'; // Import axios
import AsyncStorage from '@react-native-async-storage/async-storage';

// Define an interface for the student data structure (optional but recommended)
interface StudentProfile { // This is the structure our component uses
  name: string;
  email: string;
  rollNumber: string;
  department: string;
  year: number;
}

// This interface matches the raw response from the backend API
interface ApiStudentProfile {
  first_name: string;
  last_name: string;
  email: string;
  roll_number: string;
  department_name: string;
  current_year: number;
  // Add other relevant fields based on your API response
  // Example: mobileNumber?: string; address?: string;
}

const ProfileScreen = () => {
  const [profile, setProfile] = useState<StudentProfile | null>(null);
  const [isLoading, setIsLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchProfileData = async () => {
      setIsLoading(true);
      setError(null);


      try {
        // --- Get token and studentId from AsyncStorage in parallel ---
        const studentId = await AsyncStorage.getItem("studentID")
        const token = await AsyncStorage.getItem('studentToken');
        if ( !studentId) {
          // Handle case where token or ID is not found (e.g., user not logged in)
          setError('Authentication details not found. Please log in again.');
          setIsLoading(false);
          // Optional: Redirect to login screen
          // router.replace('/student/login');
          return;
        }

        // --- Make the request with the Authorization header ---
        // The endpoint now includes the studentId from AsyncStorage
        const response = await axios.get<ApiStudentProfile>(
          `https://gec-mis-backend.onrender.com/api/details/profile/${studentId}`
        );

        // --- Transform API data to match frontend interface ---
        const apiData = response.data;
        const formattedProfile: StudentProfile = {
          name: `${apiData.first_name} ${apiData.last_name}`,
          email: apiData.email,
          rollNumber: apiData.roll_number,
          department: apiData.department_name,
          year: apiData.current_year,
        };

        setProfile(formattedProfile);
      } catch (err) {
        console.error("Failed to fetch profile:", err);

        let errorMessage = 'Failed to load profile data. Please try again later.';
        if (axios.isAxiosError(err)) {
          const axiosError = err as AxiosError;
          if (axiosError.response) {
            errorMessage = `Failed to load profile data. Server responded with status ${axiosError.response.status}.`;
             // Specific handling for 401
             if (axiosError.response.status === 401) {
                errorMessage += ' Invalid or expired token.';
      
             }
          } else if (axiosError.request) {
            errorMessage = 'Failed to load profile data. No response from server.';
          } else {
            errorMessage = `Failed to load profile data. Error: ${axiosError.message}`;
          }
        } else if (err instanceof Error) {
           errorMessage = `Failed to load profile data. ${err.message}`;
        }

        setError(errorMessage);
      } finally {
        setIsLoading(false);
      }
    };

    fetchProfileData();
  }, []);

  // --- Render Logic ---

  if (isLoading) {
    return (
      <SafeAreaView style={styles.centered}>
        <ActivityIndicator size="large" color="#0000ff" />
        <Text>Loading Profile...</Text>
      </SafeAreaView>
    );
  }

  if (error) {
    return (
      <SafeAreaView style={styles.centered}>
        <Text style={styles.errorText}>{error}</Text>
        {/* Optionally add a retry button */}
      </SafeAreaView>
    );
  }

   if (!profile) {
     return (
       <SafeAreaView style={styles.centered}>
         <Text>No profile data found.</Text>
       </SafeAreaView>
     )
   }

  // --- Main Profile Display ---
  return (
    <SafeAreaView style={styles.container}>
      {/* <Header title="Profile" /> Optional: If you have a Header component */}
      <View style={styles.profileCard}>
        <Text style={styles.label}>Name:</Text>
        <Text style={styles.value}>{profile.name}</Text>

        <Text style={styles.label}>Roll Number:</Text>
        <Text style={styles.value}>{profile.rollNumber}</Text>

        <Text style={styles.label}>Email:</Text>
        <Text style={styles.value}>{profile.email}</Text>

        <Text style={styles.label}>Department:</Text>
        <Text style={styles.value}>{profile.department}</Text>

        <Text style={styles.label}>Year:</Text>
        <Text style={styles.value}>{profile.year}</Text>

        {/* Add other fields as needed */}
      </View>
      {/* Add other UI elements as required */}
    </SafeAreaView>
  );
};

// --- Styles ---
// (Styles remain the same as the previous example)
const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  centered: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  profileCard: {
    margin: 20,
    padding: 20,
    borderRadius: 8,
    backgroundColor: '#fff',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  label: {
    fontSize: 16,
    fontWeight: 'bold',
    color: '#555',
    marginTop: 10,
  },
  value: {
    fontSize: 16,
    color: '#333',
    marginBottom: 5,
  },
  errorText: {
    color: 'red',
    textAlign: 'center',
  },
});

export default ProfileScreen;
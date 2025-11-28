import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, StyleSheet, ActivityIndicator, Alert } from 'react-native';
import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useRouter } from 'expo-router';

const AdminLoginScreen = () => {
  const router = useRouter();
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async () => {
    if (!username || !password) {
      Alert.alert('Error', 'Please enter both username and password.');
      return;
    }

    setIsLoading(true);
    const payload={
      username:username,
      password:password
    }

    try {
      const response = await axios.post('https://gec-mis-backend.onrender.com/api/adminauth/adminLogin',payload,{headers:{'Content-Type':'application/json',},});

      if (response.data && response.data.admin) {
        // Store admin data in AsyncStorage
        await AsyncStorage.setItem('adminData', JSON.stringify(response.data.admin));
        Alert.alert('Success', 'Login successful!');
        router.push('/admin/dashboard');
      } else {
        Alert.alert('Error', response.data.message || 'Unknown error occurred.');
      }
    } catch (err: any) {
      console.error('Login error:', err);
      Alert.alert('Error', err.response?.data?.message || 'An error occurred during login.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <View style={styles.card}>
        <Text style={styles.title}>Admin Login</Text>

        <TextInput
          style={styles.input}
          placeholder="Username"
          value={username}
          onChangeText={setUsername}
          autoCapitalize="none"
        />
        <TextInput
          style={styles.input}
          placeholder="Password"
          value={password}
          onChangeText={setPassword}
          secureTextEntry
        />

        <TouchableOpacity
          onPress={handleLogin}
          style={[styles.button, isLoading && { backgroundColor: '#93c5fd' }]}
          disabled={isLoading}
        >
          {isLoading ? <ActivityIndicator color="#fff" /> : <Text style={styles.buttonText}>Login</Text>}
        </TouchableOpacity>

        <TouchableOpacity onPress={() => router.push('/admin/register')}>
          <Text style={styles.registerLink}>Don’t have an account? Register</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: { flex: 1, justifyContent: 'center', alignItems: 'center', backgroundColor: '#f3f4f6' },
  card: { width: '85%', backgroundColor: '#fff', borderRadius: 10, padding: 20, elevation: 4 },
  title: { fontSize: 24, fontWeight: 'bold', textAlign: 'center', marginBottom: 20 },
  input: { borderWidth: 1, borderColor: '#ccc', borderRadius: 8, padding: 10, marginBottom: 12 },
  button: { backgroundColor: '#2563eb', paddingVertical: 12, borderRadius: 8, alignItems: 'center' },
  buttonText: { color: '#fff', fontSize: 16, fontWeight: 'bold' },
  registerLink: { textAlign: 'center', color: '#2563eb', marginTop: 10 },
});

export default AdminLoginScreen;

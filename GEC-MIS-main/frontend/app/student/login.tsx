import React, { useState } from 'react';
import { 
  View, 
  Text, 
  TextInput, 
  TouchableOpacity, 
  StyleSheet, 
  Alert, 
  ActivityIndicator,
  StatusBar,
  Dimensions,
  KeyboardAvoidingView,
  Platform,
  ScrollView
} from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { useRouter } from 'expo-router';
import axios from 'axios';
import Svg, { Path, Defs, LinearGradient, Stop } from 'react-native-svg';

const { width, height } = Dimensions.get('window');

const LoginScreen = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const router = useRouter();

  const handleLogin = async () => {
    // Basic validation
    if (!email || !password) {
      Alert.alert('Error', 'Please enter both email and password.');
      return;
    }
    // Email format validation (basic)
    if (!/\S+@\S+\.\S+/.test(email)) {
      Alert.alert('Error', 'Please enter a valid email address.');
      return;
    }

    setLoading(true);

    try {
      const payload = {
        email: email,
        password: password
      };

      // Call the login API
      const response = await axios.post('https://gec-mis-backend.onrender.com/api/auth/login', payload, {
        headers: {
          'Content-Type': 'application/json',
        },
      });

        try {
          await AsyncStorage.setItem("studentID",response.data._id)
          await AsyncStorage.setItem("token",response.data.token)
          console.log(response.data.token)
        } catch (storageError) {
          console.error('Failed to save data to storage:', storageError);
          Alert.alert('Storage Error', 'Could not save login session. Please try again.');
        }

      console.log('Login successful:', response.data);
      Alert.alert('Success', 'Login successful!');
      router.push('/student/home');

    } catch (error: any) {
      console.error('Login failed:', error);
      let errorMessage = 'Login failed. Please check your credentials and try again.';
      if (axios.isAxiosError(error) && error.response && error.response.data && error.response.data.message) {
        errorMessage = error.response.data.message;
      } else if (error instanceof Error) {
        errorMessage = error.message;
      }
      Alert.alert('Error', errorMessage);
    } finally {
      setLoading(false);
    }
  };

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" />
      
      {/* Background gradient */}
      <View style={styles.svgWrapper}>
        <Svg height={height} width={width}>
          <Defs>
            <LinearGradient id="grad1" x1="0%" y1="0%" x2="0%" y2="100%">
              <Stop offset="0%" stopColor="#6DB3E8" stopOpacity="1" />
              <Stop offset="100%" stopColor="#4A90D9" stopOpacity="1" />
            </LinearGradient>
            <LinearGradient id="grad2" x1="0%" y1="0%" x2="0%" y2="100%">
              <Stop offset="0%" stopColor="#5D9BCC" stopOpacity="0.9" />
              <Stop offset="100%" stopColor="#3E7CB1" stopOpacity="0.9" />
            </LinearGradient>
          </Defs>
          <Path
            d={`M0,${height * 0.2} Q${width * 0.5},${height * 0.4} ${width},${height * 0.25} L${width},${height} L0,${height} Z`}
            fill="url(#grad1)"
          />
          <Path
            d={`M0,${height * 0.32} Q${width * 0.6},${height * 0.52} ${width},${height * 0.37} L${width},${height} L0,${height} Z`}
            fill="url(#grad2)"
          />
        </Svg>
      </View>

      <KeyboardAvoidingView 
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        style={styles.keyboardView}
      >
        <ScrollView 
          contentContainerStyle={styles.scrollContent}
          showsVerticalScrollIndicator={false}
        >
          {/* Header Section */}
          <View style={styles.headerSection}>
            <Text style={styles.title}>Student Login</Text>
            <Text style={styles.subtitle}>Welcome ! Please login to continue</Text>
          </View>

          {/* Form Card */}
          <View style={styles.formCard}>
            <View style={styles.inputContainer}>
              <Text style={styles.label}>Email Address</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter your email"
                placeholderTextColor="#95A5A6"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Password</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter your password"
                placeholderTextColor="#95A5A6"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                editable={!loading}
              />
            </View>

            {/* Login Button */}
            <TouchableOpacity
              style={[styles.loginButton, loading && styles.buttonDisabled]}
              onPress={handleLogin}
              disabled={loading}
              activeOpacity={0.8}
            >
              {loading ? (
                <ActivityIndicator size="small" color="#FFFFFF" />
              ) : (
                <Text style={styles.loginButtonText}>Login</Text>
              )}
            </TouchableOpacity>

            {/* Divider */}
            <View style={styles.dividerContainer}>
              <View style={styles.divider} />
              <Text style={styles.dividerText}>OR</Text>
              <View style={styles.divider} />
            </View>

            {/* Register Button */}
            <TouchableOpacity
              style={styles.registerButton}
              onPress={() => router.push('/student/register')}
              disabled={loading}
              activeOpacity={0.8}
            >
              <Text style={styles.registerButtonText}>Create New Account</Text>
            </TouchableOpacity>
          </View>

          {/* Footer */}
          {/* <View style={styles.footer}>
            <TouchableOpacity onPress={() => router.back()}>
              <Text style={styles.backText}>← Back to Home</Text>
            </TouchableOpacity>
          </View> */}
        </ScrollView>
      </KeyboardAvoidingView>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#E8F1F8',
  },
  svgWrapper: {
    position: 'absolute',
    top: 0,
    left: 0,
    width: '100%',
    height: '100%',
  },
  keyboardView: {
    flex: 1,
  },
  scrollContent: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingTop: height * 0.1,
    paddingBottom: 40,
  },
  headerSection: {
    alignItems: 'center',
    marginBottom: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: '800',
    color: '#1E3A5F',
    marginBottom: 8,
    textShadowColor: 'rgba(0, 0, 0, 0.1)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 4,
  },
  subtitle: {
    fontSize: 15,
    color: '#4A6B8A',
    textAlign: 'center',
  },
  formCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 20,
    padding: 24,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.1,
    shadowRadius: 12,
    elevation: 8,
  },
  inputContainer: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 8,
    letterSpacing: 0.3,
  },
  input: {
    height: 50,
    borderColor: '#D5E1EA',
    borderWidth: 1.5,
    borderRadius: 12,
    paddingHorizontal: 16,
    fontSize: 16,
    color: '#2C3E50',
    backgroundColor: '#F8FAFB',
  },
  loginButton: {
    backgroundColor: '#4A90D9',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: 8,
    shadowColor: '#4A90D9',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 6,
  },
  buttonDisabled: {
    opacity: 0.7,
  },
  loginButtonText: {
    fontSize: 18,
    fontWeight: '700',
    color: '#FFFFFF',
    letterSpacing: 0.5,
  },
  dividerContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginVertical: 24,
  },
  divider: {
    flex: 1,
    height: 1,
    backgroundColor: '#D5E1EA',
  },
  dividerText: {
    marginHorizontal: 16,
    fontSize: 14,
    color: '#95A5A6',
    fontWeight: '600',
  },
  registerButton: {
    backgroundColor: 'transparent',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 2,
    borderColor: '#4A90D9',
  },
  registerButtonText: {
    fontSize: 16,
    fontWeight: '700',
    color: '#4A90D9',
    letterSpacing: 0.3,
  },
  footer: {
    marginTop: 32,
    alignItems: 'center',
  },
  backText: {
    fontSize: 16,
    color: '#4A6B8A',
    fontWeight: '600',
  },
});

export default LoginScreen;
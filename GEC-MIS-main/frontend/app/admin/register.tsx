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
import { useRouter } from 'expo-router';
import axios from 'axios';
import Svg, { Path, Defs, LinearGradient, Stop } from 'react-native-svg';

const { width, height } = Dimensions.get('window');

const AdminRegisterScreen = () => {
  const router = useRouter();

  const [username, setUsername] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('');
  const [departmentId, setDepartmentId] = useState('');
  const [adminSecret, setAdminSecret] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleRegister = async () => {
    if (!username || !email || !password || !role || !departmentId || !adminSecret) {
      Alert.alert('Error', 'Please fill in all fields.');
      return;
    }

    setIsLoading(true);
    try {
      const response = await axios.post('https://gec-mis-backend.onrender.com/api/adminauth/register', {
        username,
        email,
        password,
        role,
        department_id: departmentId,
        admin_secret: adminSecret,
      });

      if (response.status === 201) {
        Alert.alert('Success', 'Admin registered successfully!');
        router.push('/admin/login');
      } else {
        Alert.alert('Error', response.data.message || 'Unknown error occurred.');
      }
    } catch (err: any) {
      console.error('Registration error:', err);
      Alert.alert('Error', err.response?.data?.message || 'An error occurred during registration.');
    } finally {
      setIsLoading(false);
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
            d={`M0,${height * 0.15} Q${width * 0.5},${height * 0.35} ${width},${height * 0.2} L${width},${height} L0,${height} Z`}
            fill="url(#grad1)"
          />
          <Path
            d={`M0,${height * 0.27} Q${width * 0.6},${height * 0.47} ${width},${height * 0.32} L${width},${height} L0,${height} Z`}
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
            <Text style={styles.title}>Admin Registration</Text>
            <Text style={styles.subtitle}>Create a new admin account</Text>
          </View>

          {/* Form Card */}
          <View style={styles.formCard}>
            <View style={styles.inputContainer}>
              <Text style={styles.label}>Username</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter username"
                placeholderTextColor="#95A5A6"
                value={username}
                onChangeText={setUsername}
                autoCapitalize="none"
                editable={!isLoading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Email Address</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter email address"
                placeholderTextColor="#95A5A6"
                value={email}
                onChangeText={setEmail}
                keyboardType="email-address"
                autoCapitalize="none"
                editable={!isLoading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Password</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter password"
                placeholderTextColor="#95A5A6"
                value={password}
                onChangeText={setPassword}
                secureTextEntry
                editable={!isLoading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Role</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter role (e.g., HOD, Faculty)"
                placeholderTextColor="#95A5A6"
                value={role}
                onChangeText={setRole}
                editable={!isLoading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Department ID</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter department ID"
                placeholderTextColor="#95A5A6"
                value={departmentId}
                onChangeText={setDepartmentId}
                editable={!isLoading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Admin Secret Key</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter admin secret key"
                placeholderTextColor="#95A5A6"
                value={adminSecret}
                onChangeText={setAdminSecret}
                secureTextEntry
                editable={!isLoading}
              />
            </View>

            {/* Register Button */}
            <TouchableOpacity
              style={[styles.registerButton, isLoading && styles.buttonDisabled]}
              onPress={handleRegister}
              disabled={isLoading}
              activeOpacity={0.8}
            >
              {isLoading ? (
                <ActivityIndicator size="small" color="#FFFFFF" />
              ) : (
                <Text style={styles.registerButtonText}>Register</Text>
              )}
            </TouchableOpacity>

            {/* Login Link */}
            <View style={styles.loginLinkContainer}>
              <TouchableOpacity
                onPress={() => router.push('/admin/login')}
                disabled={isLoading}
                activeOpacity={0.7}
              >
                <Text style={styles.loginLinkText}>Already have an account? <Text style={styles.loginLinkBold}>Login</Text></Text>
              </TouchableOpacity>
            </View>
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
    paddingTop: height * 0.08,
    paddingBottom: 40,
  },
  headerSection: {
    alignItems: 'center',
    marginBottom: 32,
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
    paddingHorizontal: 20,
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
    marginBottom: 16,
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
  registerButton: {
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
  registerButtonText: {
    fontSize: 18,
    fontWeight: '700',
    color: '#FFFFFF',
    letterSpacing: 0.5,
  },
  loginLinkContainer: {
    alignItems: 'center',
    marginTop: 20,
  },
  loginLinkText: {
    fontSize: 15,
    color: '#4A6B8A',
  },
  loginLinkBold: {
    color: '#4A90D9',
    fontWeight: '700',
  },
  footer: {
    marginTop: 24,
    alignItems: 'center',
  },
  backText: {
    fontSize: 16,
    color: '#4A6B8A',
    fontWeight: '600',
  },
});

export default AdminRegisterScreen;
import React, { useState, useEffect } from 'react';
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
  ScrollView,
  Image
} from 'react-native';
import { useRouter } from 'expo-router';
import axios from 'axios';
import * as ImagePicker from 'expo-image-picker';
import Svg, { Path, Defs, LinearGradient, Stop } from 'react-native-svg';

const { width, height } = Dimensions.get('window');

const RegisterScreen = () => {
  const router = useRouter();

  // Form fields
  const [firstName, setFirstName] = useState('');
  const [lastName, setLastName] = useState('');
  const [rollNo, setRollNo] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [dateOfBirth, setDateOfBirth] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [address, setAddress] = useState('');
  const [enrollmentNumber, setEnrollmentNumber] = useState('');
  const [admissionYear, setAdmissionYear] = useState('');
  const [currentYear, setCurrentYear] = useState('');
  const [currentSemester, setCurrentSemester] = useState('');
  const [departmentName, setDepartmentName] = useState('');
  const [imageUri, setImageUri] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    (async () => {
      if (Platform.OS !== 'web') {
        const { status } = await ImagePicker.requestMediaLibraryPermissionsAsync();
        if (status !== 'granted') {
          Alert.alert('Permission Denied', 'Sorry, we need camera roll permissions to make this work!');
        }
      }
    })();
  }, []);

  const pickImage = async () => {
    let result = await ImagePicker.launchImageLibraryAsync({
      mediaTypes: ImagePicker.MediaTypeOptions.Images,
      allowsEditing: true,
      aspect: [1, 1],
      quality: 0.5,
    });

    if (!result.canceled && result.assets && result.assets.length > 0) {
      setImageUri(result.assets[0].uri);
    }
  };

  const handleRegister = async () => {
    const requiredFields = {
      firstName, lastName, dateOfBirth, email, password, phoneNumber,
      address, enrollmentNumber, rollNo, admissionYear, currentYear,
      currentSemester, departmentName
    };
    
    for (const [key, value] of Object.entries(requiredFields)) {
      if (!value) {
        Alert.alert('Error', `Please fill in the ${key.replace(/([A-Z])/g, ' $1').toLowerCase()} field.`);
        return;
      }
    }
    
    if (!/\S+@\S+\.\S+/.test(email)) {
      Alert.alert('Error', 'Please enter a valid email address.');
      return;
    }
    
    if (password.length < 6) {
      Alert.alert('Error', 'Password must be at least 6 characters long.');
      return;
    }

    setLoading(true);

    const formData = new FormData();
    formData.append('first_name', firstName);
    formData.append('last_name', lastName);
    formData.append('date_of_birth', dateOfBirth);
    formData.append('email', email);
    formData.append('password', password);
    formData.append('phone_number', phoneNumber);
    formData.append('address', address);
    formData.append('enrollment_number', enrollmentNumber);
    formData.append('roll_number', rollNo);
    formData.append('admission_year', admissionYear);
    formData.append('current_year', currentYear);
    formData.append('current_semester', currentSemester);
    formData.append('department_name', departmentName);

    if (imageUri) {
      const uriParts = imageUri.split('.');
      const fileType = uriParts[uriParts.length - 1];
      const fileName = imageUri.split('/').pop() || `photo.${fileType}`;

      const file = {
        uri: imageUri,
        name: fileName,
        type: `image/${fileType}`,
      };
      formData.append('profile_image', file as any);
    }

    try {
      // Make the API call with FormData
      const response = await axios.post('https://gec-mis-backend.onrender.com/api/auth/register', formData, {
        headers: {
        },
      });

      console.log('Registration successful:', response.data);
      Alert.alert('Success', 'Registration successful!', [
        { text: 'OK', onPress: () => router.push('/student/login') }
      ]);

    } catch (error: any) {
      console.error('Registration failed:', error);
      let errorMessage = 'Registration failed. Please try again.';
      if (axios.isAxiosError(error)) {
        if (error.response?.data?.message) {
          errorMessage = error.response.data.message;
        } else if (error.message) {
          errorMessage = error.message;
        }
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
            d={`M0,${height * 0.12} Q${width * 0.5},${height * 0.3} ${width},${height * 0.17} L${width},${height} L0,${height} Z`}
            fill="url(#grad1)"
          />
          <Path
            d={`M0,${height * 0.22} Q${width * 0.6},${height * 0.4} ${width},${height * 0.27} L${width},${height} L0,${height} Z`}
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
            <Text style={styles.title}>Student Registration</Text>
            <Text style={styles.subtitle}>Create your new account</Text>
          </View>

          {/* Form Card */}
          <View style={styles.formCard}>
            {/* Profile Image Picker */}
            <View style={styles.imagePickerSection}>
              <TouchableOpacity onPress={pickImage} style={styles.imagePickerButton}>
                {imageUri ? (
                  <Image source={{ uri: imageUri }} style={styles.profileImage} />
                ) : (
                  <View style={styles.placeholderImage}>
                    <Text style={styles.placeholderText}>+</Text>
                    <Text style={styles.placeholderSubtext}>Add Photo</Text>
                  </View>
                )}
              </TouchableOpacity>
            </View>

            {/* Personal Information */}
            <View style={styles.inputContainer}>
              <Text style={styles.label}>First Name</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter first name"
                placeholderTextColor="#95A5A6"
                value={firstName}
                onChangeText={setFirstName}
                autoCapitalize="words"
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Last Name</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter last name"
                placeholderTextColor="#95A5A6"
                value={lastName}
                onChangeText={setLastName}
                autoCapitalize="words"
                editable={!loading}
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
                editable={!loading}
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
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Date of Birth</Text>
              <TextInput
                style={styles.input}
                placeholder="YYYY-MM-DD"
                placeholderTextColor="#95A5A6"
                value={dateOfBirth}
                onChangeText={setDateOfBirth}
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Phone Number</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter phone number"
                placeholderTextColor="#95A5A6"
                value={phoneNumber}
                onChangeText={setPhoneNumber}
                keyboardType="phone-pad"
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Address</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter address"
                placeholderTextColor="#95A5A6"
                value={address}
                onChangeText={setAddress}
                autoCapitalize="words"
                editable={!loading}
              />
            </View>

            {/* Academic Information */}
            <View style={styles.inputContainer}>
              <Text style={styles.label}>Enrollment Number</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter enrollment number"
                placeholderTextColor="#95A5A6"
                value={enrollmentNumber}
                onChangeText={setEnrollmentNumber}
                autoCapitalize="characters"
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Roll Number</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter roll number"
                placeholderTextColor="#95A5A6"
                value={rollNo}
                onChangeText={setRollNo}
                keyboardType="numeric"
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Admission Year</Text>
              <TextInput
                style={styles.input}
                placeholder="YYYY"
                placeholderTextColor="#95A5A6"
                value={admissionYear}
                onChangeText={setAdmissionYear}
                keyboardType="numeric"
                maxLength={4}
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Current Academic Year</Text>
              <TextInput
                style={styles.input}
                placeholder="1, 2, 3, or 4"
                placeholderTextColor="#95A5A6"
                value={currentYear}
                onChangeText={setCurrentYear}
                keyboardType="numeric"
                maxLength={1}
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Current Semester</Text>
              <TextInput
                style={styles.input}
                placeholder="1 to 8"
                placeholderTextColor="#95A5A6"
                value={currentSemester}
                onChangeText={setCurrentSemester}
                keyboardType="numeric"
                maxLength={1}
                editable={!loading}
              />
            </View>

            <View style={styles.inputContainer}>
              <Text style={styles.label}>Department Name</Text>
              <TextInput
                style={styles.input}
                placeholder="Enter department name"
                placeholderTextColor="#95A5A6"
                value={departmentName}
                onChangeText={setDepartmentName}
                autoCapitalize="words"
                editable={!loading}
              />
            </View>

            {/* Register Button */}
            <TouchableOpacity
              style={[styles.registerButton, loading && styles.buttonDisabled]}
              onPress={handleRegister}
              disabled={loading}
              activeOpacity={0.8}
            >
              {loading ? (
                <ActivityIndicator size="small" color="#FFFFFF" />
              ) : (
                <Text style={styles.registerButtonText}>Register</Text>
              )}
            </TouchableOpacity>

            {/* Login Link */}
            <View style={styles.loginLinkContainer}>
              <TouchableOpacity
                onPress={() => router.push('/student/login')}
                disabled={loading}
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
    justifyContent: 'center',
    paddingHorizontal: 24,
    paddingTop: 40,
    paddingBottom: 40,
  },
  headerSection: {
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: '800',
    color: '#1E3A5F',
    marginBottom: 6,
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
  imagePickerSection: {
    alignItems: 'center',
    marginBottom: 16,
  },
  imagePickerButton: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  profileImage: {
    width: 100,
    height: 100,
    borderRadius: 50,
    borderWidth: 3,
    borderColor: '#4A90D9',
  },
  placeholderImage: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: '#F8FAFB',
    borderWidth: 2,
    borderColor: '#D5E1EA',
    borderStyle: 'dashed',
    alignItems: 'center',
    justifyContent: 'center',
  },
  placeholderText: {
    fontSize: 32,
    color: '#4A90D9',
    fontWeight: '300',
  },
  placeholderSubtext: {
    fontSize: 12,
    color: '#95A5A6',
    marginTop: 4,
  },
  inputContainer: {
    marginBottom: 12,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#2C3E50',
    marginBottom: 8,
    letterSpacing: 0.3,
  },
  input: {
    height: 48,
    borderColor: '#D5E1EA',
    borderWidth: 1.5,
    borderRadius: 12,
    paddingHorizontal: 16,
    fontSize: 15,
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
    marginTop: 16,
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
    marginTop: 20,
    alignItems: 'center',
  },
  backText: {
    fontSize: 16,
    color: '#4A6B8A',
    fontWeight: '600',
  },
});

export default RegisterScreen;
import React from 'react';
import {
  StyleSheet,
  Text,
  View,
  Image,
  TouchableOpacity,
  StatusBar,
  Dimensions
} from 'react-native';
import Svg, { Path, Defs, LinearGradient, Stop } from 'react-native-svg';
import { useRouter } from 'expo-router';

const { width, height } = Dimensions.get('window');

export default function WelcomeScreen() {
  const router = useRouter(); 

  return (
    <View style={styles.container}>
      <StatusBar barStyle="light-content" />

      {/* Enhanced gradient background */}
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
            d={`M0,${height * 0.25} Q${width * 0.5},${height * 0.5} ${width},${height * 0.35} L${width},${height} L0,${height} Z`}
            fill="url(#grad1)"
          />
          <Path
            d={`M0,${height * 0.38} Q${width * 0.6},${height * 0.63} ${width},${height * 0.48} L${width},${height} L0,${height} Z`}
            fill="url(#grad2)"
          />
        </Svg>
      </View>

      <View style={styles.contentContainer}>
        {/* Header with centered alignment */}
        <View style={styles.headerSection}>
          <View style={styles.logoRow}>
            <Image
              source={require('../assets/gec-seal.png')}
              style={styles.sealLogo}
              resizeMode="contain"
            />
          </View>
          
          <View style={styles.titleContainer}>
            <Text style={styles.title}>GEC's</Text>
            <Text style={styles.subtitle}>Management Information</Text>
            <Text style={styles.subtitle}>System Application</Text>
          </View>

          <View style={styles.taglineContainer}>
            <Text style={styles.tagline}>Your Gateway to Administration Excellence</Text>
          </View>
        </View>

        {/* Enhanced buttons section */}
        <View style={styles.footerSection}>
          <Text style={styles.getStartedText}>Get Started as</Text>
          
          <View style={styles.buttonGroup}>
            <TouchableOpacity 
              style={[styles.button, styles.studentButton]}
              onPress={() => router.push('/student/login')}
              activeOpacity={0.8}
            >
              <Text style={styles.buttonText}>Student</Text>
            </TouchableOpacity>
            
            <TouchableOpacity 
              style={[styles.button, styles.adminButton]}
              onPress={() => router.push('/admin/login')}
              activeOpacity={0.8}
            >
              <Text style={styles.buttonText}>Admin</Text>
            </TouchableOpacity>
          </View>

          <View style={styles.versionContainer}>
            <Text style={styles.versionText}>Version 1.0.0</Text>
          </View>
        </View>
      </View>
    </View>
  );
}

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
  contentContainer: {
    flex: 1,
    paddingHorizontal: 32,
    justifyContent: 'space-between',
    paddingTop: height * 0.12,
    paddingBottom: height * 0.08,
  },
  headerSection: {
    alignItems: 'center',
  },
  logoRow: {
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 36,
  },
  sealLogo: {
    width: 100,
    height: 100,
  },
  titleContainer: {
    alignItems: 'center',
    marginBottom: 20,
  },
  title: {
    fontSize: 48,
    fontWeight: '800',
    color: '#1E3A5F',
    letterSpacing: 0.5,
    textShadowColor: 'rgba(0, 0, 0, 0.1)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 4,
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 24,
    color: '#2C3E50',
    lineHeight: 32,
    fontWeight: '600',
    letterSpacing: 0.3,
    textAlign: 'center',
  },
  taglineContainer: {
    marginTop: 12,
    paddingTop: 20,
    paddingHorizontal: 20,
    borderTopWidth: 2,
    borderTopColor: 'rgba(255, 255, 255, 0.3)',
  },
  tagline: {
    fontSize: 15,
    color: '#4A6B8A',
    fontStyle: 'italic',
    fontWeight: '500',
    textAlign: 'center',
  },
  footerSection: {
    alignItems: 'center',
    width: '100%',
  },
  getStartedText: {
    fontSize: 18,
    fontWeight: '600',
    color: '#FFFFFF',
    marginBottom: 24,
    letterSpacing: 1,
    textTransform: 'uppercase',
    opacity: 0.95,
  },
  buttonGroup: {
    width: '100%',
    flexDirection: 'row',
    gap: 12,
  },
  button: {
    flex: 1,
    borderRadius: 14,
    paddingVertical: 16,
    paddingHorizontal: 20,
    alignItems: 'center',
    justifyContent: 'center',
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.15,
    shadowRadius: 6,
    elevation: 5,
  },
  studentButton: {
    backgroundColor: '#FFFFFF',
  },
  adminButton: {
    backgroundColor: '#FFFFFF',
  },
  buttonText: {
    fontSize: 16,
    color: '#4A90D9',
    fontWeight: '700',
    letterSpacing: 0.3,
  },
  versionContainer: {
    marginTop: 20,
    opacity: 0.7,
  },
  versionText: {
    fontSize: 12,
    color: '#FFFFFF',
    fontWeight: '400',
  },
});
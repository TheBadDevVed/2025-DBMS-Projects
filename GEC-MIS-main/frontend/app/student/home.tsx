// File: app/home.tsx

import { Feather } from "@expo/vector-icons";
import { BlurView } from 'expo-blur';
import axios from 'axios';
import { useRouter } from "expo-router";
import React, { useEffect, useRef, useState } from "react";
import {
  Animated,
  Dimensions,
  Image,
  Linking,
  Modal,
  Pressable,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
  ActivityIndicator,
  ImageBackground
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";

const { width, height } = Dimensions.get("window");

const sidebarMenuItems = [
  { icon: "home", name: "Home", route: "/student/home" }, // Or just "." if already on home
  { icon: "user", name: "Profile", route: "/student/profile" },
  { icon: "settings", name: "Reset Password", route: "/student/reset-password" },
  { icon: "award", name: "Semester Result", route: "/student/semester-result" },
  { icon: "dollar-sign", name: "My Payments", route: "/student/payments" }, // Typo fixed
];

export default function HomeScreen() {
  const router = useRouter();
  const [isSidebarVisible, setSidebarVisible] = useState(false);
  const [selectedNotice, setSelectedNotice] = useState<any | null>(null);
  const [notices, setNotices] = useState<any[]>([]);
  const [loadingNotices, setLoadingNotices] = useState(true);
  const [noticeError, setNoticeError] = useState<string | null>(null);

  const slideAnim = useRef(new Animated.Value(-width * 0.8)).current;

  const toggleSidebar = (visible: boolean) => {
    setSidebarVisible(visible);
    Animated.timing(slideAnim, {
      toValue: visible ? 0 : -width * 0.8,
      duration: 300,
      useNativeDriver: true,
    }).start();
  };

  useEffect(() => {
    const fetchNotices = async () => {
      try {
        setLoadingNotices(true);
        setNoticeError(null);
        const response = await axios.get('https://gec-mis-backend.onrender.com/api/details/home');
        // The backend returns { success: true, data: notices }
        if (response.data && Array.isArray(response.data.data)) {
          setNotices(response.data.data);
        }
      } catch (err: any) {
        setNoticeError(err.response?.data?.message || 'Failed to fetch notices.');
      } finally {
        setLoadingNotices(false);
      }
    };
    fetchNotices();
  }, []);

  const handleLogout = () => {
    AsyncStorage.removeItem("token");
    AsyncStorage.removeItem("studentID");
    toggleSidebar(false);
    // CORRECTED: Changed absolute path to relative route
    router.push("/student/login");
  };

  // This function is now correct because AppRoutes and sidebarMenuItems are corrected
  const handleMenuItemPress = (route: string) => {
    toggleSidebar(false);
    setTimeout(() => {
      router.push(route as AppRoutes);
    }, 150);
  };
  
  const handleNoticePress = (notice: any) => {
    setSelectedNotice(notice);
  };

  const handleCloseNoticeModal = () => {
    setSelectedNotice(null);
  };

  const handleLinkPress = (url: string) => {
    Linking.openURL(url).catch(err => console.error("Couldn't load page", err));
  };
  
  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />

      {/* --- Sidebar Modal --- */}
      <Modal
        animationType="fade"
        transparent={true}
        visible={isSidebarVisible}
        onRequestClose={() => toggleSidebar(false)}
      >
        <Pressable
          style={styles.modalOverlay}
          onPress={() => toggleSidebar(false)}
        >
          <Animated.View
            style={[
              styles.sidebarContainer,
              { transform: [{ translateX: slideAnim }] },
            ]}
            onStartShouldSetResponder={() => true}
          >
            {/* Sidebar Top Section - Graduation Background */}
            <ImageBackground
              // CORRECTED: Changed path from ../assets to ../../assets
              source={require("../../assets/image_cf3603.jpg")}
              style={styles.sidebarTopSection}
            >
              <View style={styles.profileInfoWrapper}>
                {/* CORRECTED: Use relative route name */}
                <TouchableOpacity onPress={() => handleMenuItemPress('profile')}>
                  
                </TouchableOpacity>
              </View>
            </ImageBackground>

            {/* Sidebar Menu Section - Building Background with Blur */}
            <ImageBackground
              source={{ uri: "https://placehold.co/600x800/8AB9E0/FFFFFF?text=Building+Background" }}
              style={styles.sidebarMenuSection}
            >
              <BlurView intensity={80} tint="light" style={StyleSheet.absoluteFill}>
                <ScrollView contentContainerStyle={styles.menuScrollView}>
                  {/* Main Menu Items */}
                  <View style={styles.sidebarMenu}>
                    {sidebarMenuItems.map((item, index) => (
                      <TouchableOpacity
                        key={index}
                        style={styles.sidebarMenuItem}
                        onPress={() => handleMenuItemPress(item.route as AppRoutes)}
                      >
                        <Feather
                          name={item.icon as any}
                          size={24}
                          color="#E57373"
                        />
                        <Text style={styles.sidebarMenuItemText}>{item.name}</Text>
                      </TouchableOpacity>
                    ))}
                  </View>

                  {/* Separator Line */}
                  <View style={styles.separator} />

                  {/* Bottom Menu Items (Contact Us and Logout) */}
                  <View style={styles.sidebarMenu}>
                    <TouchableOpacity
                      style={styles.sidebarMenuItem}
                      onPress={handleLogout}
                    >
                      <Feather name="log-out" size={24} color="#E57373" />
                      <Text style={styles.sidebarMenuItemText}>Log out</Text>
                    </TouchableOpacity>
                  </View>
                </ScrollView>
              </BlurView>
            </ImageBackground>
          </Animated.View>
        </Pressable>
      </Modal>

      {/* --- Notice Modal (New) --- */}
      {selectedNotice && (
        <Modal
          animationType="fade"
          transparent={true}
          visible={true}
          onRequestClose={handleCloseNoticeModal}
        >
          <Pressable style={styles.contactModalOverlay} onPress={handleCloseNoticeModal}>
            <View style={styles.noticeModalCard}>
              <View style={styles.noticeModalHeader}>
                <Text style={styles.noticeModalTitle}>{selectedNotice.title}</Text>
                <Text style={styles.noticeModalDate}>{selectedNotice.date}</Text>
              </View>
              <ScrollView>
                <Text style={styles.noticeModalDescription}>
                  {selectedNotice.description}
                </Text>
              </ScrollView>
            </View>
          </Pressable>
        </Modal>
      )}

      {/* --- Main App Content --- */}
      <View style={styles.topNavBar}>
        <TouchableOpacity
          onPress={() => toggleSidebar(true)}
          style={styles.navBarLeft}
        >
          <View style={styles.menuIconContainer}>
            <Feather name="grid" size={24} color="#E57373" />
          </View>
        </TouchableOpacity>
      </View>

      <ScrollView style={styles.scrollView}>
        <View style={styles.contentContainer}>
          {/* Admissions Section */}
          <View style={styles.admissionsSection}>
            <TouchableOpacity
              style={styles.admissionCard}
              // CORRECTED: Changed absolute path to relative route
              onPress={() => router.push("/student/be-admission")}
            >
              <ImageBackground
                source={{
                  uri: "https://placehold.co/600x200/CCCCCC/FFFFFF?text=Campus",
                }}
                style={styles.cardBackground}
                imageStyle={{ borderRadius: 12 }}
              >
                <View
                  style={[
                    styles.cardOverlay,
                    { backgroundColor: "rgba(229, 115, 115, 0.85)" },
                  ]}
                />
                <View style={styles.cardContent}>
                  <Image
                    // CORRECTED: Changed path from ../assets to ../../assets
                    source={require("../../assets/gec-seal.png")}
                    style={styles.cardLogo}
                  />
                  <View style={styles.cardTextContainer}>
                    <Text style={styles.cardTitle}>GEC B.E ADMISSION</Text>
                    <Text style={styles.cardSubtitle}>2025-26</Text>
                  </View>
                  <View style={styles.visitButton}>
                    <Text style={styles.visitButtonText}>Visit</Text>
                    <Feather name="chevron-right" size={16} color="#FFFFFF" />
                  </View>
                </View>
              </ImageBackground>
            </TouchableOpacity>

          </View>

          {/* Notices Section */}
          <View style={styles.noticesSection}>
            <Text style={styles.sectionTitle}>Notices</Text>
            {
              loadingNotices ? (
                <ActivityIndicator size="large" color="#E57373" style={{ marginTop: 20 }} />
              ) : noticeError ? (
                <Text style={styles.errorText}>{noticeError}</Text>
              ) : notices.length === 0 ? (
                <Text style={styles.noNoticesText}>No notices available at the moment.</Text>
              ) : (
                notices.map((notice) => (
                  <TouchableOpacity
                    key={notice._id}
                    style={styles.noticeCard}
                  >
                    <View style={styles.noticeHeader}>
                      <Text style={styles.noticeTitle}>{notice.title}</Text>
                      <Text style={styles.noticeDate}>
                        {new Date(notice.createdAt).toLocaleDateString()}
                      </Text>
                    </View>
                    <Text style={styles.noticeDescription} numberOfLines={3}>
                      {notice.body}
                    </Text>
                  </TouchableOpacity>
                ))
              )
            }
          </View>
        </View>
      </ScrollView>

      {/* Footer Navigation */}
      <View style={styles.footer}>
        <TouchableOpacity style={styles.footerItem}>
          <Feather
            name="home"
            style={[styles.footerIcon, styles.footerIconActive]}
          />
          <Text style={[styles.footerText, styles.footerTextActive]}>Home</Text>
        </TouchableOpacity>
        <TouchableOpacity style={styles.footerItem} onPress={handleLogout}>
          <Feather name="log-out" style={styles.footerIcon} />
          <Text style={styles.footerText}>Logout</Text>
        </TouchableOpacity>
      </View>
    </SafeAreaView>
  );
}

// ... (styles remain unchanged)
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F0F4F8",
  },
  
  topNavBar: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingHorizontal: 20,
    paddingVertical: 10,
    backgroundColor: "#F0F4F8",
  },
  navBarLeft: {
    flexDirection: "row",
    alignItems: "center",
  },
  menuIconContainer: {
    backgroundColor: "#FFF",
    padding: 8,
    borderRadius: 8,
    marginRight: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.1,
    shadowRadius: 2,
    elevation: 3,
  },
  navBarTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#34495E",
  },
  navBarSubtitle: {
    fontSize: 12,
    color: "#555",
  },

  modalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.5)",
  },
  sidebarContainer: {
    width: width * 0.8,
    height: "100%",
    backgroundColor: "transparent",
    shadowColor: "#000",
    shadowOffset: { width: 2, height: 0 },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  sidebarTopSection: {
    height: Dimensions.get('window').height * 0.3,
    justifyContent: 'center',
    alignItems: 'center',
    resizeMode: 'cover',
  },
  profileInfoWrapper: {
    alignItems: 'center',
  },
  profilePic: {
    width: 90,
    height: 90,
    borderRadius: 45,
    borderWidth: 3,
    borderColor: "#FFFFFF",
    marginBottom: 10,
  },
  profileName: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#FFFFFF",
    textShadowColor: 'rgba(0, 0, 0, 0.5)',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 3,
  },
  profileDetails: {
    fontSize: 14,
    color: "#FFFFFF",
    textShadowColor: 'rgba(0, 0, 0, 0.5)',
    textShadowOffset: { width: 1, height: 1 },
    textShadowRadius: 3,
  },
  sidebarMenuSection: {
    flex: 1,
    backgroundColor: '#FFFFFF',
    resizeMode: 'cover',
  },
  menuScrollView: {
    flexGrow: 1,
    paddingVertical: 20,
  },
  sidebarMenu: {
    flex: 1,
  },
  sidebarMenuItem: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 14,
    paddingHorizontal: 20,
  },
  sidebarMenuItemText: {
    marginLeft: 20,
    fontSize: 16,
    color: "#333",
    fontWeight: '500',
  },
  separator: {
    height: 1,
    backgroundColor: '#E0E0E0',
    marginHorizontal: 20,
    marginVertical: 10,
  },

  scrollView: {
    flex: 1,
  },
  contentContainer: {
    paddingHorizontal: 20,
    paddingBottom: 80,
  },
  admissionsSection: {
    marginTop: 10,
    marginBottom: 20,
  },
  admissionCard: {
    height: 120,
    borderRadius: 12,
    marginBottom: 15,
    backgroundColor: "#fff",
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 5,
    elevation: 6,
  },
  cardBackground: {
    flex: 1,
    justifyContent: "center",
  },
  cardOverlay: {
    position: "absolute",
    top: 0,
    left: 0,
    right: 0,
    bottom: 0,
    borderRadius: 12,
  },
  cardContent: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 20,
  },
  cardLogo: {
    width: 60,
    height: 60,
    marginRight: 15,
  },
  cardTextContainer: {
    flex: 1,
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#FFFFFF",
    letterSpacing: 1,
  },
  cardSubtitle: {
    fontSize: 16,
    color: "#FFFFFF",
    marginTop: 4,
  },
  visitButton: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "rgba(0,0,0,0.2)",
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 20,
  },
  visitButtonText: {
    color: "#FFFFFF",
    fontWeight: "bold",
    marginRight: 4,
  },
  noticesSection: {},
  sectionTitle: {
    fontSize: 22,
    fontWeight: "bold",
    color: "#34495E",
    marginBottom: 20,
  },
  noticeCard: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 20,
    marginBottom: 15,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  noticeHeader: {
    borderBottomWidth: 1,
    borderColor: "#EAEAEA",
    paddingBottom: 10,
    marginBottom: 10,
  },
  noticeTitle: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 5,
  },
  noticeDate: {
    fontSize: 12,
    color: "#888",
  },
  noticeDescription: {
    fontSize: 14,
    color: "#555",
    lineHeight: 20,
  },
  footer: {
    flexDirection: "row",
    justifyContent: "space-around",
    alignItems: "center",
    backgroundColor: "#FFFFFF",
    borderTopWidth: 1,
    borderColor: "#E0E0E0",
    paddingVertical: 8,
    position: "absolute",
    bottom: 0,
    left: 0,
    right: 0,
  },
  footerItem: {
    alignItems: "center",
    justifyContent: "center",
  },
  footerIcon: {
    fontSize: 24,
    color: "#888888",
  },
  footerText: {
    fontSize: 12,
    color: "#888888",
    marginTop: 4,
  },
  footerIconActive: {
    color: "#E57373",
  },
  footerTextActive: {
    color: "#E57373",
  },
  contactModalOverlay: {
    flex: 1,
    backgroundColor: "rgba(0, 0, 0, 0.6)",
    justifyContent: "center",
    alignItems: "center",
  },
  contactCard: {
    width: "80%",
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 25,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  contactTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#34495E",
    marginBottom: 20,
    textAlign: "center",
  },
  contactRow: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 15,
  },
  contactIcon: {
    marginRight: 15,
  },
  contactText: {
    fontSize: 16,
    color: "#555",
  },
  // New Styles for Notice Modal
  noticeModalCard: {
    width: "90%",
    height: "60%",
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    elevation: 5,
  },
  noticeModalHeader: {
    borderBottomWidth: 1,
    borderBottomColor: "#EAEAEA",
    paddingBottom: 10,
    marginBottom: 10,
  },
  noticeModalTitle: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#333",
    marginBottom: 5,
  },
  noticeModalDate: {
    fontSize: 14,
    color: "#888",
  },
  noticeModalDescription: {
    fontSize: 16,
    color: "#555",
    lineHeight: 24,
  },
  errorText: {
    textAlign: 'center',
    color: 'red',
    marginTop: 20,
    fontSize: 16,
  },
  noNoticesText: {
    textAlign: 'center',
    color: '#666',
    marginTop: 20,
    fontSize: 16,
  },
});
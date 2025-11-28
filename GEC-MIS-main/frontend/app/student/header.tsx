// File: app/header.tsx

import { Feather } from "@expo/vector-icons";
import { useNavigation, usePathname } from 'expo-router';
import React from 'react';
import { Image, StyleSheet, Text, TouchableOpacity, View } from 'react-native';

const Header = () => {
  const navigation = useNavigation();
  const pathname = usePathname();

  const toggleSidebar = () => {
    // This is a placeholder. You'll need to link this to your actual sidebar logic.
    // navigation.openDrawer(); // If using a drawer navigator
    console.log("Toggle sidebar/profile menu");
  };
  
  const handleBack = () => {
    navigation.goBack();
  };

  const pathParts = pathname?.split('/') || [];
  const lastPart = pathParts.pop();
  
  const title = (lastPart && lastPart !== '')
    ? lastPart
        .replace(/-/g, ' ')
        .replace(/\b\w/g, (l: string) => l.toUpperCase()) // Added type annotation
    : 'Home';

  // CORRECTED: Checked against the full pathnames from the (student) group
  const isHomeOrProfile = pathname === '/student' || pathname === '/student/home' || pathname === '/student/profile';

  return (
    <View style={styles.headerContainer}>
      <TouchableOpacity onPress={isHomeOrProfile ? toggleSidebar : handleBack} style={styles.profileIconWrapper}>
        {isHomeOrProfile ? (
          <Image
            source={{ uri: "https://placehold.co/100x100/E57373/FFFFFF?text=DS" }}
            style={styles.profileImage}
          />
        ) : (
          <Feather name="arrow-left" size={24} color="#34495E" />
        )}
      </TouchableOpacity>
      <Text style={styles.headerTitle}>{title}</Text>
    </View>
  );
};

const styles = StyleSheet.create({
  headerContainer: {
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 20,
    paddingTop: 40,
    paddingBottom: 15,
    backgroundColor: "#F0F4F8",
    borderBottomWidth: 1,
    borderBottomColor: "#E0E0E0",
  },
  profileIconWrapper: {
    marginRight: 15,
  },
  profileImage: {
    width: 35,
    height: 35,
    borderRadius: 17.5,
  },
  headerTitle: {
    fontSize: 20,
    fontWeight: "bold",
    color: "#34495E",
  },
});

export default Header;
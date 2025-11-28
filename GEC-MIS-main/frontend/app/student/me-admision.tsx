// File: app/me-admission.tsx

import { useRouter } from "expo-router";
import React from "react";
import {
  Image,
  SafeAreaView,
  ScrollView,
  StatusBar,
  StyleSheet,
  Text,
  TouchableOpacity,
  View,
} from "react-native";

export default function MeAdmissionScreen() {
  const router = useRouter();

  const handleHelpdeskPress = (type: string) => {
    // Implement navigation or external link logic for helpdesk buttons
    console.log(`${type} Helpdesk button pressed`);
  };

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />

      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Registration Procedure Card */}
        <View style={styles.card}>
          <Image
            source={{ uri: "https://placehold.co/600x400/FFFFFF/5D9BCC?text=Registration+Procedure" }}
            style={styles.imagePlaceholder}
          />
          <TouchableOpacity
            style={styles.helpdeskButton}
            onPress={() => handleHelpdeskPress("ME_Admission")}
          >
            <Text style={styles.helpdeskButtonText}>ME_Admission_Helpdesk</Text>
          </TouchableOpacity>
        </View>

        {/* Electronics Engineering Card */}
        <View style={styles.card}>
          <Image
            source={{ uri: "https://placehold.co/600x400/FFFFFF/5D9BCC?text=Electronics+Engineering" }}
            style={styles.imagePlaceholder}
          />
        </View>

        {/* Anti-Ragging Card */}
        <View style={styles.card}>
          <Image
            source={{ uri: "https://placehold.co/600x400/FFFFFF/5D9BCC?text=Anti-Ragging+Notice" }}
            style={styles.imagePlaceholder}
          />
          <TouchableOpacity
            style={styles.helpdeskButton}
            onPress={() => handleHelpdeskPress("Anti_ragging")}
          >
            <Text style={styles.helpdeskButtonText}>Anti_ragging_Helpdesk</Text>
          </TouchableOpacity>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#F0F4F8",
  },
  scrollContent: {
    padding: 20,
    paddingTop: 0,
    paddingBottom: 40,
  },
  card: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 10,
    marginBottom: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  imagePlaceholder: {
    width: "100%",
    height: 300, 
    borderRadius: 10,
    resizeMode: "contain", 
  },
  helpdeskButton: {
    marginTop: 15,
    marginBottom: 5,
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 20,
    borderWidth: 1.5,
    borderColor: "#5D9BCC",
    alignSelf: "center",
  },
  helpdeskButtonText: {
    color: "#5D9BCC",
    fontWeight: "bold",
    fontSize: 14,
  },
});
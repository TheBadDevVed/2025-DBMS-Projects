// File: app/payments.tsx

import { Feather } from "@expo/vector-icons";
import { useRouter } from "expo-router";
import React, { useEffect, useState } from "react";
import {
    Image,
    SafeAreaView,
    ScrollView,
    StatusBar,
    StyleSheet,
    Text,
    TouchableOpacity,
    View,
    ActivityIndicator,
} from "react-native";
import axios from "axios";
import AsyncStorage from "@react-native-async-storage/async-storage";

// Payments fetched from API: http://localhost:3000/api/details/getFeeDetails
// Expected item shape fallback: { id, academicYear, semester, amount }

export default function PaymentsScreen() {
  const router = useRouter();
  const [payments, setPayments] = useState<any[]>([]);
  const [loading, setLoading] = useState<boolean>(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let mounted = true;
    const fetchPayments = async () => {
      try {
        setLoading(true);
        setError(null);
        const studentId=await AsyncStorage.getItem("studentID")
        const token=await AsyncStorage.getItem("token")
        // Backend returns an array of Fee documents per getFeeDetails
        const { data } = await axios.get(`https://gec-mis-backend.onrender.com/api/details/getFeeDetails/${studentId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
          withCredentials: true,
        });
        const items = Array.isArray(data) ? data : (Array.isArray(data?.data) ? data.data : []);
        const normalized = items.map((it: any, idx: number) => ({
          id: String(it._id ?? it.id ?? idx),
          academicYear: it.academic_year ?? it.academicYear ?? it.ay ?? it.year ?? "",
          semester: it.semester ? `Semester ${it.semester}` : (it.sem ?? ""),
          amount: String(it.amount ?? it.feeAmount ?? it.total ?? "0"),
        }));
        if (mounted) setPayments(normalized);
      } catch (e: any) {
        const msg = e?.response?.data?.message || e?.message || "Something went wrong";
        if (mounted) setError(msg);
      } finally {
        if (mounted) setLoading(false);
      }
    };
    fetchPayments();
    return () => { mounted = false; };
  }, []);

  return (
    <SafeAreaView style={styles.container}>
      <StatusBar barStyle="dark-content" />

      <ScrollView contentContainerStyle={styles.scrollContent}>
        <View style={styles.paymentSection}>
          <TouchableOpacity
            style={styles.sectionHeader}
            onPress={() => router.push('/exam-fees')}
          >
            <Text style={styles.sectionTitle}>Tuition Fee Payments</Text>
    
          </TouchableOpacity>

          {loading && (
            <View style={{ paddingVertical: 20, alignItems: 'center' }}>
              <ActivityIndicator size="small" color="#34495E" />
              <Text style={{ marginTop: 8, color: '#666' }}>Loading payments…</Text>
            </View>
          )}

          {!!error && (
            <Text style={{ color: 'crimson', marginBottom: 10 }}>Error: {error}</Text>
          )}

          {!loading && !error && payments.length === 0 && (
            <Text style={{ color: '#666' }}>No fee details if there are no details available</Text>
          )}

          {!loading && !error && payments.map((payment) => (
            <View key={payment.id} style={styles.paymentCard}>
              <View style={styles.paymentDetails}>
                <Image
                  source={{ uri: "https://placehold.co/100x100/5D9BCC/FFFFFF?text=Logo" }}
                  style={styles.paymentLogo}
                />
                <View>
                  <Text style={styles.paymentTitle}>{payment.academicYear} {payment.semester}</Text>
                  <Text style={styles.paymentAmount}>
                    Amount - Rs.{payment.amount}
                  </Text>
                </View>
              </View>
              <TouchableOpacity style={styles.downloadButton}>
                <Feather name="download" size={24} color="#8AB9E0" />
              </TouchableOpacity>
            </View>
          ))}
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
  },
  paymentSection: {
    backgroundColor: "#FFFFFF",
    borderRadius: 12,
    padding: 20,
    shadowColor: "#000",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 20,
    paddingBottom: 10,
    borderBottomWidth: 1,
    borderBottomColor: "#E0E0E0",
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: "bold",
    color: "#34495E",
  },
  paymentCard: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    paddingVertical: 15,
    borderBottomWidth: 1,
    borderBottomColor: "#F0F0F0",
  },
  paymentCardLast: {
    borderBottomWidth: 0,
  },
  paymentDetails: {
    flexDirection: "row",
    alignItems: "center",
  },
  paymentLogo: {
    width: 40,
    height: 40,
    borderRadius: 20,
    marginRight: 15,
  },
  paymentTitle: {
    fontSize: 16,
    fontWeight: "bold",
    color: "#333",
  },
  paymentAmount: {
    fontSize: 14,
    color: "#666",
    marginTop: 4,
  },
  downloadButton: {
    padding: 8,
  },
});
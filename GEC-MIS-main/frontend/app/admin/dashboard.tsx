import React, { useEffect, useRef, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Dimensions,
  Pressable,
  ScrollView,
  RefreshControl,
} from 'react-native';
import { Stack, useRouter } from 'expo-router';

const SIDEBAR_WIDTH = 260;

const AdminDashboard = () => {
  const router = useRouter();
  const [open, setOpen] = useState(false);
  const translateX = useRef(new Animated.Value(-SIDEBAR_WIDTH)).current;

  // Notice state
  const [notices, setNotices] = useState<any[]>([]);
  const [loading, setLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);
  const [refreshing, setRefreshing] = useState(false);

  const BASE_URL = process.env.EXPO_PUBLIC_API_URL || 'https://gec-mis-backend.onrender.com';

  const fetchNotices = async () => {
    setLoading(true);
    setError(null);
    try {
      const res = await fetch(`${BASE_URL}/api/adminDetails/viewNotice`);
      if (!res.ok) throw new Error(`HTTP ${res.status}`);
      const data = await res.json();
      setNotices(Array.isArray(data) ? data : data?.data ?? []);
    } catch (e: any) {
      setError(e?.message ?? 'Failed to load notices');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    let isMounted = true;
    const load = async () => {
      setLoading(true);
      try {
        const res = await fetch(`${BASE_URL}/api/adminDetails/viewNotice`);
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        const data = await res.json();
        if (isMounted) {
          setNotices(Array.isArray(data) ? data : data?.data ?? []);
        }
      } catch (e: any) {
        if (isMounted) setError(e?.message ?? 'Failed to load notices');
      } finally {
        if (isMounted) setLoading(false);
      }
    };
    load();
    return () => {
      isMounted = false;
    };
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await fetchNotices();
    setRefreshing(false);
  };

  const toggleSidebar = () => {
    const toValue = open ? -SIDEBAR_WIDTH : 0;
    setOpen(!open);
    Animated.timing(translateX, {
      toValue,
      duration: 250,
      useNativeDriver: true,
    }).start();
  };

  const navigate = (path: string) => {
    if (open) toggleSidebar();
    router.push(path as any);
  };

  return (
    <View style={styles.root}>
      <Stack.Screen options={{ title: 'Admin Dashboard' }} />

      {/* Top bar */}
      <View style={styles.topBar}>
        <TouchableOpacity onPress={toggleSidebar} style={styles.menuButton}>
          <Text style={styles.menuButtonText}>☰</Text>
        </TouchableOpacity>
        <Text style={styles.topBarTitle}>Admin Dashboard</Text>
      </View>

      {/* Main Content - MOVED HERE */}
      {/* This is now rendered FIRST, so it appears at the bottom of the stack */}
      <ScrollView
        style={styles.content}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
        }>
        <Text style={styles.welcome}>Welcome to the Admin Dashboard</Text>
        <Text style={styles.helper}>
          Use the menu button to open the sidebar and navigate.
        </Text>

        <View style={styles.noticeHeaderRow}>
          <Text style={styles.noticeHeader}>Notices</Text>
          <View style={{ flexDirection: 'row', alignItems: 'center', gap: 8 }}>
            <TouchableOpacity
              onPress={() => navigate('/admin/createNotice')}
              style={styles.createButton}>
              <Text style={styles.createButtonText}>Create Notice</Text>
            </TouchableOpacity>
            {loading && <Text style={styles.noticeMeta}>Loading...</Text>}
          </View>
        </View>

        {error ? (
          <Text style={styles.errorText}>{error}</Text>
        ) : notices.length === 0 && !loading ? (
          <Text style={styles.emptyText}>No notices available.</Text>
        ) : (
          <View style={styles.noticeList}>
            {notices.map((n, idx) => (
              <View key={n._id ?? idx} style={styles.noticeCard}>
                <Text style={styles.noticeTitle}>
                  {n.title ?? 'Untitled Notice'}
                </Text>
                {n.body ? (
                  <Text style={styles.noticeBody}>{n.body}</Text>
                ) : null}
                <Text style={styles.noticeMeta}>
                  {n.createdAt
                    ? new Date(n.createdAt).toLocaleString()
                    : ''}
                </Text>
              </View>
            ))}
          </View>
        )}
      </ScrollView>

      {/* Backdrop overlay - MOVED HERE */}
      {/* This is rendered SECOND, so it appears on top of the content */}
      {open && <Pressable style={styles.backdrop} onPress={toggleSidebar} />}

      {/* Sidebar - MOVED HERE */}
      {/* This is rendered LAST, so it appears on top of both the content and the backdrop */}
      <Animated.View style={[styles.sidebar, { transform: [{ translateX }] }]}>
        <Text style={styles.sidebarTitle}>Menu</Text>
        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigate('/admin/addStudentDetails')}>
          <Text style={styles.navText}>Add Student Details</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigate('/admin/viewStudentDetails')}>
          <Text style={styles.navText}>View Student Details</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={styles.navItem}
          onPress={() => navigate('/admin/updateStudentDetails')}>
          <Text style={styles.navText}>Update Student Details</Text>
        </TouchableOpacity>
      </Animated.View>

    </View>
  );
};

// Styles (unchanged)
const styles = StyleSheet.create({
  root: {
    flex: 1,
    backgroundColor: '#F0F4F8',
  },
  topBar: {
    height: 56,
    backgroundColor: '#5D9BCC',
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 12,
  },
  menuButton: {
    width: 40,
    height: 40,
    borderRadius: 8,
    backgroundColor: '#8AB9E0',
    alignItems: 'center',
    justifyContent: 'center',
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },
  menuButtonText: {
    color: '#FFFFFF',
    fontSize: 20,
    fontWeight: '700',
  },
  topBarTitle: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '700',
    marginLeft: 12,
  },
  backdrop: {
    position: 'absolute',
    left: 0,
    right: 0,
    top: 56, // Start below topBar
    bottom: 0,
    backgroundColor: 'rgba(52,73,94,0.25)',
  },
  sidebar: {
    position: 'absolute',
    left: 0,
    top: 56, // Start below topBar
    bottom: 0,
    width: SIDEBAR_WIDTH,
    backgroundColor: '#5D9BCC',
    paddingTop: 24,
    paddingHorizontal: 16,
    elevation: 5, // Ensures it's above other elements on Android
    shadowColor: '#5D9BCC',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.25,
    shadowRadius: 4,
    borderRightWidth: 1,
    borderRightColor: '#8AB9E0',
  },
  sidebarTitle: {
    color: '#FFFFFF',
    fontSize: 18,
    fontWeight: '700',
    marginBottom: 16,
  },
  navItem: {
    backgroundColor: '#8AB9E0',
    paddingVertical: 12,
    paddingHorizontal: 12,
    borderRadius: 10,
    marginBottom: 10,
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },
  navText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: '600',
  },
  content: {
    flex: 1, // Make sure it fills the available space
    padding: 24,
    // Add a background color to prevent transparency issues
    // This isn't strictly necessary after reordering, but good practice
    backgroundColor: '#F0F4F8',
  },
  welcome: {
    fontSize: 24,
    fontWeight: '800',
    marginTop: 16,
    marginBottom: 8,
    color: '#34495E',
  },
  helper: {
    fontSize: 14,
    color: '#555',
  },
  noticeHeaderRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    marginTop: 16,
  },
  noticeHeader: {
    fontSize: 18,
    fontWeight: '700',
    color: '#34495E',
  },
  noticeList: {
    marginTop: 10,
  },
  noticeCard: {
    backgroundColor: '#FFFFFF',
    padding: 12,
    borderRadius: 12,
    marginBottom: 10,
    borderWidth: 1,
    borderColor: '#8AB9E0',
    shadowColor: '#5D9BCC',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.15,
    shadowRadius: 3,
    elevation: 2,
  },
  noticeTitle: {
    fontSize: 16,
    fontWeight: '700',
    color: '#34495E',
    marginBottom: 4,
  },
  noticeBody: {
    fontSize: 14,
    color: '#555',
    marginBottom: 6,
  },
  noticeMeta: {
    fontSize: 12,
    color: '#555',
  },
  errorText: {
    color: '#FF3B30',
    marginTop: 12,
  },
  emptyText: {
    color: '#555',
    marginTop: 12,
  },
  createButton: {
    backgroundColor: '#5D9BCC',
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 10,
    borderWidth: 1.5,
    borderColor: '#FFFFFF',
  },
  createButtonText: {
    color: '#FFFFFF',
    fontWeight: '700',
  },
});

export default AdminDashboard;
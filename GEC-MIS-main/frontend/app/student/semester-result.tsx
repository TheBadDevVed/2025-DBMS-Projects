
import React, { useEffect, useState } from 'react';
import { View, Text, FlatList, StyleSheet, ActivityIndicator } from 'react-native';
import AsyncStorage from '@react-native-async-storage/async-storage';
import axios from 'axios';

const SemesterResult = () => {
  const [results, setResults] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchResults = async () => {
      setLoading(true);
      setError(null);
      try {
        const studentId=await AsyncStorage.getItem("studentID")
        const token=await AsyncStorage.getItem("token")
        const response = await axios.get(`https://gec-mis-backend.onrender.com/api/details/getResult/${studentId}`, {
          headers: {
            Authorization: `Bearer ${token}`,
          },
        });
        setResults(response.data);
      } catch (err) {
        setError(
          err.response?.data?.message || 'Failed to fetch results. Please try again.'
        );
      } finally {
        setLoading(false);
      }
    };
    fetchResults();
  }, []);

  const renderCourse = (course, idx) => (
    <View key={idx} style={styles.courseContainer}>
      <Text style={styles.courseName}>{course.course_name} ({course.course_code})</Text>
      <Text>Internal: {course.internal_marks ?? '-'}</Text>
      <Text>Term Work: {course.term_work_marks ?? '-'}</Text>
      <Text>End Sem: {course.end_sem_exam_marks ?? '-'}</Text>
      <Text>Grade: {course.grade ?? '-'}</Text>
    </View>
  );

  const renderSemester = ({ item }) => (
    <View style={styles.semesterContainer}>
      <Text style={styles.semesterTitle}>Semester {item.semester}</Text>
      <Text>Academic Year: {item.academic_year}</Text>
      <Text>SGPA: {item.sgpa ?? '-'}</Text>
      <Text>CGPA: {item.cgpa ?? '-'}</Text>
      <Text>Registration Status: {item.registration_status}</Text>
      <Text>Registration Date: {item.registration_date ? new Date(item.registration_date).toLocaleDateString() : '-'}</Text>
      <Text style={styles.coursesHeader}>Courses:</Text>
      {item.courses && item.courses.length > 0 ? (
        item.courses.map(renderCourse)
      ) : (
        <Text>No courses found for this semester.</Text>
      )}
    </View>
  );

  if (loading) {
    return <ActivityIndicator size="large" color="#0000ff" style={{ marginTop: 40 }} />;
  }

  if (error) {
    return (
      <View style={styles.errorContainer}>
        <Text style={styles.errorText}>{error}</Text>
      </View>
    );
  }

  if (!results || results.length === 0) {
    return (
      <View style={styles.emptyContainer}>
        <Text>No results found.</Text>
      </View>
    );
  }

  return (
    <FlatList
      data={results}
      keyExtractor={(item) => item._id}
      renderItem={renderSemester}
      contentContainerStyle={styles.listContent}
    />
  );
};

export default SemesterResult;

const styles = StyleSheet.create({
  /* Page layout */
  container: {
    flex: 1,
    backgroundColor: '#F0F4F8',
  },
  listContent: {
    paddingBottom: 30,
  },

  /* Semester card */
  semesterContainer: {
    backgroundColor: '#FFFFFF',
    borderRadius: 12,
    padding: 16,
    marginVertical: 10,
    marginHorizontal: 16,
    elevation: 3,
  },
  semesterTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#34495E',
    marginBottom: 6,
  },
  academicYear: {
    fontSize: 12,
    color: '#999',
    marginTop: 2,
  },
  semesterStatsContainer: {
    flexDirection: 'row',
    marginRight: 12,
  },
  statItem: {
    alignItems: 'center',
    marginRight: 16,
  },
  statLabel: {
    fontSize: 11,
    color: '#999',
    fontWeight: '600',
  },
  statValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#E57373',
    marginTop: 2,
  },

  /* Courses */
  coursesHeader: {
    marginTop: 10,
    fontWeight: 'bold',
    color: '#1a2b44',
  },
  courseContainer: {
    marginTop: 6,
    marginBottom: 6,
    padding: 8,
    backgroundColor: '#F9F9F9',
    borderRadius: 8,
    elevation: 1,
  },
  courseName: {
    fontSize: 13,
    color: '#555',
    marginBottom: 10,
    fontWeight: '500',
  },
  courseCode: {
    fontSize: 13,
    fontWeight: 'bold',
    color: '#34495E',
    backgroundColor: '#E8F5E9',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 4,
    marginRight: 8,
  },
  gradeBadge: {
    paddingHorizontal: 10,
    paddingVertical: 4,
    borderRadius: 4,
  },
  gradeBadgeText: {
    color: '#FFFFFF',
    fontSize: 12,
    fontWeight: 'bold',
  },

  /* Marks layout */
  marksContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  markItem: {
    flex: 1,
    alignItems: 'center',
    paddingHorizontal: 4,
  },
  totalMarkItem: {
    backgroundColor: '#FFF3E0',
    borderRadius: 6,
    paddingVertical: 6,
  },
  markLabel: {
    fontSize: 11,
    color: '#999',
    fontWeight: '600',
    marginBottom: 4,
  },
  markValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#34495E',
  },
  totalMarkValue: {
    fontSize: 14,
    fontWeight: 'bold',
    color: '#F57C00',
  },

  /* Helper cards */
  infoCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: '#E3F2FD',
    borderRadius: 8,
    padding: 12,
    marginBottom: 15,
    borderLeftWidth: 4,
    borderLeftColor: '#2196F3',
  },
  infoText: {
    marginLeft: 12,
    fontSize: 14,
    color: '#1565C0',
    flex: 1,
  },

  /* Empty / error states */
  centerContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: 20,
  },
  loadingText: {
    marginTop: 12,
    fontSize: 16,
    color: '#666',
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 20,
  },
  errorText: {
    marginTop: 12,
    fontSize: 16,
    color: '#F44336',
    textAlign: 'center',
  },
  retryButton: {
    marginTop: 20,
    paddingHorizontal: 30,
    paddingVertical: 12,
    backgroundColor: '#E57373',
    borderRadius: 8,
  },
  retryButtonText: {
    color: '#FFFFFF',
    fontSize: 16,
    fontWeight: 'bold',
  },
  noDataText: {
    marginTop: 12,
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
  },
  noDataSubText: {
    marginTop: 8,
    fontSize: 14,
    color: '#999',
    textAlign: 'center',
  },
  noCourses: {
    paddingVertical: 20,
    alignItems: 'center',
  },
  noCoursesText: {
    fontSize: 14,
    color: '#999',
  },
});



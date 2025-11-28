import React, { useState } from 'react';
import { View, Text, StyleSheet, TextInput, TouchableOpacity, ScrollView, Alert, ActivityIndicator } from 'react-native';
import { Stack } from 'expo-router';
import axios from 'axios';

interface Student {
  _id: string;
  first_name: string;
  last_name: string;
  roll_number: string;
  enrollment_number: string;
  email: string;
  current_year: number;
  current_semester: number;
  department_name: string;
  phone_number: string;
}

const ViewStudentDetails = () => {
  const [filters, setFilters] = useState({
    name: '',
    'roll-no': '',
    year: '',
    department: ''
  });

  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSearch = async () => {
    setLoading(true);
    setError('');

    try {
      // Only include non-empty filters
      const filterData = Object.fromEntries(
        Object.entries(filters).filter(([_, value]) => value !== '')
      );

      const response = await axios.get('https://gec-mis-backend.onrender.com/api/adminDetails/studentDetails', {
        params: filterData
      });

      if (response.data.success) {
        setStudents(response.data.data);
        if (response.data.data.length === 0) {
          setError('No students found matching the criteria');
        }
      }
    } catch (error) {
      console.error('Error fetching student details:', error);
      setError('Failed to fetch student details');
      setStudents([]);
    } finally {
      setLoading(false);
    }
  };

  const clearFilters = () => {
    setFilters({
      name: '',
      'roll-no': '',
      year: '',
      department: ''
    });
    setStudents([]);
    setError('');
  };

  const renderStudent = (student: Student) => (
    <View key={student._id} style={styles.studentCard}>
      <Text style={styles.studentName}>
        {student.first_name} {student.last_name}
      </Text>
      <View style={styles.detailRow}>
        <Text style={styles.label}>Roll Number:</Text>
        <Text style={styles.value}>{student.roll_number}</Text>
      </View>
      <View style={styles.detailRow}>
        <Text style={styles.label}>Enrollment:</Text>
        <Text style={styles.value}>{student.enrollment_number}</Text>
      </View>
      <View style={styles.detailRow}>
        <Text style={styles.label}>Email:</Text>
        <Text style={styles.value}>{student.email}</Text>
      </View>
      <View style={styles.detailRow}>
        <Text style={styles.label}>Year:</Text>
        <Text style={styles.value}>{student.current_year}</Text>
      </View>
      <View style={styles.detailRow}>
        <Text style={styles.label}>Department:</Text>
        <Text style={styles.value}>{student.department_name}</Text>
      </View>
      <View style={styles.detailRow}>
        <Text style={styles.label}>Semester:</Text>
        <Text style={styles.value}>{student.current_semester}</Text>
      </View>
      {student.phone_number && (
        <View style={styles.detailRow}>
          <Text style={styles.label}>Phone:</Text>
          <Text style={styles.value}>{student.phone_number}</Text>
        </View>
      )}
    </View>
  );

  return (
    <ScrollView style={styles.container}>
      <Stack.Screen options={{ title: 'View Student Details' }} />

      {/* Filters Section */}
      <View style={styles.filtersContainer}>
        <Text style={styles.sectionTitle}>Search Filters</Text>
        <TextInput
          style={styles.input}
          placeholder="Student Name"
          value={filters.name}
          onChangeText={(value) => setFilters(prev => ({ ...prev, name: value }))}
        />
        <TextInput
          style={styles.input}
          placeholder="Roll Number"
          value={filters['roll-no']}
          onChangeText={(value) => setFilters(prev => ({ ...prev, 'roll-no': value }))}
        />
        <TextInput
          style={styles.input}
          placeholder="Year (1-4)"
          value={filters.year}
          onChangeText={(value) => setFilters(prev => ({ ...prev, year: value }))}
          keyboardType="numeric"
        />
        <TextInput
          style={styles.input}
          placeholder="Department"
          value={filters.department}
          onChangeText={(value) => setFilters(prev => ({ ...prev, department: value }))}
        />

        <View style={styles.buttonContainer}>
          <TouchableOpacity style={styles.searchButton} onPress={handleSearch}>
            <Text style={styles.buttonText}>Search</Text>
          </TouchableOpacity>
          <TouchableOpacity style={styles.clearButton} onPress={clearFilters}>
            <Text style={styles.buttonText}>Clear Filters</Text>
          </TouchableOpacity>
        </View>
      </View>

      {/* Results Section */}
      {loading ? (
        <ActivityIndicator size="large" color="#007AFF" style={styles.loader} />
      ) : error ? (
        <Text style={styles.errorText}>{error}</Text>
      ) : (
        <View style={styles.resultsContainer}>
          {students.length > 0 && (
            <Text style={styles.resultsCount}>
              Found {students.length} student{students.length !== 1 ? 's' : ''}
            </Text>
          )}
          {students.map(renderStudent)}
        </View>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  filtersContainer: {
    backgroundColor: 'white',
    padding: 16,
    margin: 16,
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.25,
    shadowRadius: 3.84,
    elevation: 5,
  },
  sectionTitle: {
    fontSize: 20,
    fontWeight: 'bold',
    marginBottom: 16,
    color: '#333',
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    padding: 12,
    marginBottom: 12,
    backgroundColor: '#fff',
  },
  buttonContainer: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    gap: 12,
  },
  searchButton: {
    flex: 1,
    backgroundColor: '#007AFF',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  clearButton: {
    flex: 1,
    backgroundColor: '#FF3B30',
    padding: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  loader: {
    marginTop: 20,
  },
  errorText: {
    color: '#FF3B30',
    textAlign: 'center',
    margin: 20,
    fontSize: 16,
  },
  resultsContainer: {
    padding: 16,
  },
  resultsCount: {
    fontSize: 16,
    color: '#666',
    marginBottom: 16,
  },
  studentCard: {
    backgroundColor: 'white',
    padding: 16,
    borderRadius: 10,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 3,
  },
  studentName: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 12,
  },
  detailRow: {
    flexDirection: 'row',
    marginBottom: 8,
  },
  label: {
    flex: 1,
    fontSize: 14,
    color: '#666',
    fontWeight: '500',
  },
  value: {
    flex: 2,
    fontSize: 14,
    color: '#333',
  },
});

export default ViewStudentDetails;

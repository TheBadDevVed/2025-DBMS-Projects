import React, { useState } from 'react';
import { View, Text, TextInput, StyleSheet, TouchableOpacity, Alert } from 'react-native';
import { Stack, useRouter } from 'expo-router';

const CreateNotice = () => {
  const router = useRouter();
  const [title, setTitle] = useState('');
  const [body, setBody] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const onSubmit = async () => {
    if (!title.trim() || !body.trim()) {
      Alert.alert('Validation', 'Please fill both title and body');
      return;
    }
    setSubmitting(true);
    setError(null);
    try {
      const res = await fetch('https://gec-mis-backend.onrender.com/api/adminDetails/createNotice', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: title.trim(), body: body.trim() }),
      });
      if (!res.ok) {
        const t = await res.text();
        throw new Error(`HTTP ${res.status}: ${t}`);
      }
      // Optionally parse response
      // const data = await res.json();
      Alert.alert('Success', 'Notice created successfully');
      router.replace('/admin/dashboard');
    } catch (e: any) {
      setError(e?.message ?? 'Failed to create notice');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <View style={styles.root}>
      <Stack.Screen options={{ title: 'Create Notice' }} />
      <Text style={styles.title}>Create Notice</Text>

      <Text style={styles.label}>Title</Text>
      <TextInput
        value={title}
        onChangeText={setTitle}
        placeholder="Enter title"
        style={styles.input}
      />

      <Text style={styles.label}>Body</Text>
      <TextInput
        value={body}
        onChangeText={setBody}
        placeholder="Enter body"
        style={[styles.input, styles.textarea]}
        multiline
        numberOfLines={6}
      />

      {error ? <Text style={styles.errorText}>{error}</Text> : null}

      <TouchableOpacity disabled={submitting} onPress={onSubmit} style={[styles.button, submitting && { opacity: 0.7 }] }>
        <Text style={styles.buttonText}>{submitting ? 'Submitting...' : 'Create'}</Text>
      </TouchableOpacity>

      <TouchableOpacity onPress={() => router.back()} style={styles.secondaryButton}>
        <Text style={styles.secondaryButtonText}>Cancel</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  root: {
    flex: 1,
    padding: 24,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 22,
    fontWeight: '800',
    marginBottom: 16,
    color: '#111827',
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    marginTop: 12,
    marginBottom: 6,
    color: '#111827',
  },
  input: {
    backgroundColor: '#ffffff',
    borderWidth: 1,
    borderColor: '#e5e7eb',
    borderRadius: 8,
    paddingHorizontal: 12,
    paddingVertical: 10,
  },
  textarea: {
    height: 120,
    textAlignVertical: 'top',
  },
  button: {
    marginTop: 20,
    backgroundColor: '#2563EB',
    paddingVertical: 12,
    borderRadius: 8,
    alignItems: 'center',
  },
  buttonText: {
    color: '#ffffff',
    fontWeight: '700',
  },
  secondaryButton: {
    marginTop: 12,
    paddingVertical: 10,
    alignItems: 'center',
  },
  secondaryButtonText: {
    color: '#1f2937',
    fontWeight: '600',
  },
  errorText: {
    color: '#FF3B30',
    marginTop: 12,
  },
});

export default CreateNotice;

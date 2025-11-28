// File: app/_layout.tsx

import { Stack } from 'expo-router';
import React from 'react';
import Header from './header';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen 
        name="index" 
        options={{ 
          headerShown: false 
        }} 
      />
      <Stack.Screen 
        name="login" 
        options={{ 
          title: 'Login',
          headerStyle: { backgroundColor: '#5D9BCC' }, 
          headerTintColor: '#FFFFFF', 
          headerTitleStyle: { fontWeight: 'bold' },
          headerShadowVisible: false, 
        }} 
      />
      <Stack.Screen 
        name="register"
        options={{
          headerShown: false,
        }}
      />
      <Stack.Screen
        name="home"
        options={{
          header: () => <Header />,
          title: 'Home',
        }}
      />
      <Stack.Screen
        name="payments"
        options={{
          header: () => <Header />,
          title: 'My Payments',
        }}
      />
      <Stack.Screen
        name="exam-fees"
        options={{
          header: () => <Header />,
          title: 'Exam Fee Payments',
        }}
      />
      <Stack.Screen
        name="info"
        options={{
          header: () => <Header />,
          title: 'Information',
        }}
      />
      <Stack.Screen
        name="profile"
        options={{
          header: () => <Header />,
          title: 'Profile',
        }}
      />
      <Stack.Screen
        name="be-admission"
        options={{
          header: () => <Header />,
          title: 'BE Admission',
        }}
      />
      <Stack.Screen
        name="me-admission"
        options={{
          header: () => <Header />,
          title: 'ME Admission',
        }}
      />
    </Stack>
  );
}
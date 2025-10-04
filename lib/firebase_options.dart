import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCCWvy7zyafQiHjWhthGGS5eItpekI5z-Q',
    appId: '1:281452909965:web:YOUR_WEB_APP_ID',
    messagingSenderId: '281452909965',
    projectId: 'mtqmn-quranicare',
    authDomain: 'mtqmn-quranicare.firebaseapp.com',
    storageBucket: 'mtqmn-quranicare.firebasestorage.app',
    measurementId: 'YOUR_MEASUREMENT_ID',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCCWvy7zyafQiHjWhthGGS5eItpekI5z-Q',
    appId: '1:281452909965:android:5dd982adafc47efcb019c4',
    messagingSenderId: '281452909965',
    projectId: 'mtqmn-quranicare',
    storageBucket: 'mtqmn-quranicare.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '281452909965',
    projectId: 'mtqmn-quranicare',
    storageBucket: 'mtqmn-quranicare.firebasestorage.app',
    iosBundleId: 'com.mtqmn.quranicare',
  );
}

/* 
==========================================
LANGKAH SETUP FIREBASE:
==========================================

1. Buat Firebase Project:
   - Pergi ke https://console.firebase.google.com
   - Klik "Add project" atau "Tambah proyek"
   - Beri nama project: "quranicare-app"
   - Ikuti langkah setup

2. Enable Firestore Database:
   - Di Firebase Console, pilih "Firestore Database"
   - Klik "Create database"
   - Pilih "Start in test mode" (untuk development)
   - Pilih lokasi server (pilih yang terdekat)

3. Setup Authentication (opsional):
   - Di sidebar, pilih "Authentication"
   - Klik "Get started"
   - Di tab "Sign-in method", enable metode yang diinginkan

4. Konfigurasi Android:
   - Di Firebase Console, klik "Add app" > pilih Android
   - Masukkan package name: com.example.quranicare
   - Download google-services.json
   - Letakkan di android/app/google-services.json
   - Tambahkan plugin di android/build.gradle:
     classpath 'com.google.gms:google-services:4.4.0'
   - Tambahkan di android/app/build.gradle:
     apply plugin: 'com.google.gms.google-services'

5. Konfigurasi Web (opsional):
   - Klik "Add app" > pilih Web
   - Beri nama app: "QuraniCare Web"
   - Copy Firebase config dan ganti di file ini

6. Update Firebase Options:
   - Ganti placeholder di file ini dengan config dari Firebase Console
   - Atau gunakan FlutterFire CLI:
     npm install -g firebase-tools
     dart pub global activate flutterfire_cli
     flutterfire configure

==========================================
SECURITY RULES untuk Firestore:
==========================================

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Breathing Exercises - read only untuk semua user
    match /breathing_exercises/{exerciseId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Categories - read only
    match /breathing_categories/{categoryId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // User Sessions - hanya user yang bersangkutan yang bisa read/write
    match /user_breathing_sessions/{sessionId} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.user_id;
    }
    
    // Audio Files - read only
    match /breathing_audio_files/{audioId} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
  }
}

==========================================
SAMPLE FIRESTORE INDEXES (otomatis):
==========================================

Firestore akan otomatis membuat index untuk:
- breathing_exercises: category, difficulty_level, is_active
- user_breathing_sessions: user_id, exercise_id, session_date

Jika ada error composite index, Firestore akan memberikan link 
untuk membuat index yang diperlukan.

*/
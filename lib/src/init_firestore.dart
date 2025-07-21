import 'dart:io';

import 'package:synchronized_tracked_time_list/src/account.dart';
import 'package:firebase_core_dart/firebase_core_dart.dart';
Future<void> initFire() async {
    // --- FIREBASE ADMIN INITIALIZATION ---
  final serviceAccount = ServiceAccount.fromJsonFile(
    accountFile: File('example/mgr-telavox-server-firebase-adminsdk-fbsvc-d14433a337.json')
  );
  

FirebaseOptions options = FirebaseOptions.fromMap(serviceAccount.toJson());
 
  // Initialize the app with your project ID and credentials
  final adminApp = await Firebase.initializeApp(options: options);
  
  // Get the Firestore instance from the initialized app

  print("🔥 Firebase Admin SDK Initialized");

}